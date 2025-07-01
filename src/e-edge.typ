#import "imports.typ": elembic as e

#let MARKS = (
  // TODO replace once https://github.com/Jollywatt/typst-fletcher/pull/57 lands
  stealth: (
    size: 6,
    stealth: 0.3,
    angle: 25deg,

    tip-origin: mark => 0.5/calc.sin(mark.angle),
    tail-origin: mark => {
      let (cos, sin) = (calc.cos(mark.angle), calc.sin(mark.angle))

      // with stealth > 0, the tail-origin lies within the triangular hull of the mark
      // act as though the tail actually ended at the edge of the triangular hull
      // for stealth <= 0, the actual stealth length should be used
      // to avoid offsets between mark and edge
      let stealth = calc.min(mark.stealth, 0)
      let base-length = mark.size*(stealth - 1)*cos

      let miter-correction = if mark.stealth < 0 {
        // the tail-origin is at the base-length, but extended by the length of the miter join of
        // the two back edges of the arrow. this extension is the same as tip-origin, but scaled
        // with the stealth
        0.5/sin * stealth
      } else {
        // the tail-origin is at the base-length, but extended by the length of the miter join of
        // the front and back edge of the arrow. For this join, we need the angular bisector of
        // these edges

        // we can get the back edge by the law of cosines from the triangle formed by the tip
        // (tail-end), the head's back point, and the tip-end. Since we're only interested in an
        // angle, we ignore the size. We know
        // - the side opposite tip-end = 1
        // - the side opposite the back point = 1 - stealth
        // - the angle opposite the back edge = angle
        // we need the back edge and then the back point angle
        let base = (1 - mark.stealth)*cos
        let back-edge = calc.sqrt(1 + base*base - 2*base*cos)
        // using law of sines we now get the back angle
        let back-angle = calc.asin(base/back-edge * sin)

        // using half the back angle, we can compute how far the miter join will extend out
        let join-length = 0.5/calc.sin(back-angle/2)

        // adding that angle onto the mark's `angle`, we get the difference in direction between
        // the arrow's base and that miter
        let projected-length = join-length * calc.cos(mark.angle + back-angle/2)

        // apply the correction depending on whether we're over the miter limit
        if join-length < mark.stroke.miter-limit/2 {
          -projected-length
        } else {
          0
        }
      }

      base-length + miter-correction
    },
    tip-end: mark => mark.size*(mark.stealth - 1)*calc.cos(mark.angle),

    stroke: (miter-limit: 20),

    draw: mark => {
      import "imports.typ": cetz.draw

      draw.line(
        (0,0),
        (180deg + mark.angle, mark.size),
        (mark.tip-end, 0),
        (180deg - mark.angle, mark.size),
        close: true,
      )
    },

    cap-offset: (mark, y) => if mark.tip {
      -mark.stealth/calc.tan(mark.angle)*calc.abs(y)
    } else {
      calc.tan(mark.angle + 90deg)*calc.abs(y)
    },
  ),

  "plum-|>": (inherit: "stealth", angle: 30deg, stealth: 0, size: 14, fill: none),
  "plum->": (inherit: "straight", sharpness: 30deg, size: 14),
  "plum-x": (inherit: "x", size: 7),
  "plum-o": (inherit: "stealth", angle: 30deg, stealth: -1, size: 10, fill: white),
  "plum-*": (inherit: "plum-o", fill: black),
)

#let add-marks() = {
  import "imports.typ": fletcher

  fletcher.MARKS.update(marks => (: ..marks, ..MARKS))
}

#let edge = e.element.declare(
  "edge",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    [edge(#repr(it.a), #repr(it.b), #repr(it.kind.type))]
  },

  fields: (
    e.field("a", e.types.union(str, label), required: true),
    e.field("b", e.types.union(str, label), required: true),
    e.field("kind", dictionary, required: true),
    e.field("via", array, default: ()),
    e.field("bend", e.types.union(none, float), default: none),
  ),
)

#let to-fletcher(it) = {
  import "imports.typ": fletcher.edge

  let (a, b, kind, via, bend) = (via: (), bend: none, ..e.fields(it))
  if type(a) == str { a = label(a) }
  if type(b) == str { b = label(b) }

  let opts = (dash: none, marks: ())

  if kind.type in ("realization", "dependency") {
    opts.dash = "densely-dashed"
  }
  let marks = if kind.type in ("realization", "generalization") {
    if kind.direction == "a-to-b" {
      opts.marks.push(none)
    }
    opts.marks.push("plum-|>")
  } else if kind.type in ("dependency",) {
    if kind.direction == "a-to-b" {
      opts.marks.push(none)
    }
    opts.marks.push("plum->")
  } else if kind.type in ("association",) {
    let (a, b) = kind
    let marks(end, side) = {
      let nav = end.at("navigable", default: none)
      let agg = end.at("aggregation", default: none)

      // the mark at the end indicating aggregation or navigability
      let mark = if nav == true {
        "plum->"
      } else if agg == "aggregate" {
        "plum-o"
      } else if agg == "composite" {
        "plum-*"
      }
      // the non-navigability is a bit inside the line, further for aggregations
      let x-mark = if nav == false {
        let x-mark = (inherit: "plum-x")
        x-mark.extrude = (if mark != none { 27 } else { 10 },)
        x-mark += if side == "a" { (pos: 0) } else { (pos: 1, rev: true) }
        (x-mark,)
      }
      (..x-mark, mark)
    }

    opts.marks += marks(a, "a").rev()
    opts.marks += marks(b, "b")
  }

  if bend != none {
    opts.bend = bend * 1rad
  }

  edge(a, ..via, b, ..opts)
  if kind.type in ("association",) {
    let fake-edge(pos, side, label) = {
      edge(
        a, ..via, b,
        ..opts,
        stroke: black.transparentize(100%),
        marks: (),
        label: label,
        label-pos: pos,
        label-side: side,
        ..args
      )
    }

    let fake-edges(pos, visibility: none, static: false, name: none, type: none, multiplicity: none) = {
      assert(not static, message: "static edges are not allowed")
      fake-edge(pos, left, {
        set text(0.8em)
        if visibility != none [#visibility ]
        name
        if type != none [: #type]
      })
      if multiplicity != none {
        fake-edge(pos, right, {
          set text(0.8em)
          multiplicity
        })
      }
    }

    let (a, b) = kind
    if "role" in a {
      fake-edges(0.15, ..a.role)
    }
    if "role" in b {
      fake-edges(0.85, ..b.role)
    }
  }
}

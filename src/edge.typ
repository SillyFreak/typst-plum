#import "imports.typ": elembic as e

#let MARKS = (
  "plum-|>": (inherit: "stealth", angle: 30deg, stealth: 0, size: 14, fill: none),
  "plum->": (inherit: "straight", sharpness: 30deg, size: 14),
  "plum-x": (inherit: "x", size: 7),
  "plum-o": (inherit: "stealth", angle: 30deg, stealth: -1, size: 10, fill: none),
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
    e.field("bend", e.types.option(float), default: none),
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
    if kind.direction != none {
      if kind.direction == "a-to-b" {
        opts.marks.push(none)
      }
      opts.marks.push("plum->")
    }
  } else if kind.type in ("association",) {
    let (a, b) = kind
    let marks(end, side) = {
      let nav = end.at("navigable", default: none)
      let agg = end.at("aggregation", default: none)

      let pos = (pos: if side == "a" { 0 } else { 1 })

      let marks = ()
      // the mark at the end indicating aggregation or navigability
      let mark = {
        if nav == true { "plum->" }
        else if agg == "aggregate" {"plum-o" }
        else if agg == "composite" {"plum-*" }
      }
      if mark != none {
        marks.push((
          inherit: mark,
          ..pos,
          rev: side == "a",
        ))
      }
      // the non-navigability is a bit inside the line, further for aggregations
      if nav == false {
        marks.push((
          inherit: "plum-x",
          ..pos,
          rev: side == "b",
          extrude: (if marks.len() != 0 { 27 } else { 10 },),
        ))
      }

      marks
    }

    opts.marks += marks(a, "a")
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
        stroke: none,
        marks: (),
        label: label,
        label-pos: pos,
        label-side: side,
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
      fake-edges(5pt, ..a.role)
    }
    if "role" in b {
      fake-edges(100% - 5pt, ..b.role)
    }
  }
}

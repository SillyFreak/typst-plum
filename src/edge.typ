#import "imports.typ": elembic as e

#let MARKS = (
  "plum-|>": (inherit: "stealth", angle: 30deg, stealth: 0, size: 14, fill: none),
  "plum->": (inherit: "straight", sharpness: 30deg, size: 14),
  "plum-x": (inherit: "x", size: 7),
  "plum-o": (inherit: "stealth", angle: 30deg, stealth: -1, size: 10, fill: none),
  "plum-*": (inherit: "plum-o", fill: auto),
)

#let add-marks() = {
  import "imports.typ": fletcher

  fletcher.MARKS.update(marks => (: ..marks, ..MARKS))
}

#let association-end-multiplicity = e.element.declare(
  "association-end-multiplicity",
  prefix: "@preview/plum,v1",

  template: it => {
    set text(0.8em)
    it
  },

  display: it => {
    it.multiplicity
  },

  fields: (
    e.field("multiplicity", content, required: true),
  ),
)

#let association-end-role = e.element.declare(
  "association-end-role",
  prefix: "@preview/plum,v1",

  template: it => {
    set text(0.8em)
    it
  },

  display: it => {
    let (name, visibility, static, type, modifiers) = it

    show: if static { underline } else { it => it }

    let modifier(m) = {
      if std.type(m) == str {
        m
      } else if "redefines" in m {
        [redefines #m.redefines]
      } else if "subsets" in m {
        [subsets #m.redefines]
      } else if "constraint" in m {
        m.constraint
      } else {
        panic("unknown modifier: " + repr(m))
      }
    }


    if visibility != none [#visibility~]
    name
    if type != none [: #type]
    if modifiers != () [ {#modifiers.map(modifier).join[, ]}]
  },

  fields: (
    e.field("name", content, required: true),
    e.field("visibility", content, default: none),
    e.field("static", bool, default: false),
    e.field("type", e.types.option(content), default: none),
    e.field("modifiers", array, default: ()),
  ),
)

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

    // styling
    e.field("stroke", e.types.option(stroke), default: 0.3pt),
  ),
)

#let to-fletcher(it, get) = {
  import "imports.typ": fletcher

  let (a, b, kind, via, bend, stroke) = (: ..get(edge), ..e.fields(it))
  if type(a) == str { a = label(a) }
  if type(b) == str { b = label(b) }

  let opts = (stroke: stroke, dash: none, marks: ())

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
        else if agg == "aggregate" { "plum-o" }
        else if agg == "composite" { "plum-*" }
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

  fletcher.edge(a, ..via, b, ..opts)
  if kind.type in ("association",) {
    let fake-edge(pos, side, label) = {
      fletcher.edge(
        a, ..via, b,
        ..opts,
        stroke: none,
        marks: (),
        label: label,
        label-pos: pos,
        label-side: side,
      )
    }

    let fake-edges(pos, multiplicity, role) = {
      fake-edge(pos, left, role)
      if multiplicity != none {
        fake-edge(pos, right, multiplicity)
      }
    }

    let (a, b) = kind
    if "role" in a {
      fake-edges(5pt, a.at("multiplicity", default: none), a.role)
    }
    if "role" in b {
      fake-edges(100% - 5pt, b.at("multiplicity", default: none), b.role)
    }
  }
}

#import "imports.typ": elembic as e

/// The custom Fletcher marks that Plum defines; can be registered by calling @@add-marks().
///
/// -> dictionary
#let MARKS = (
  "plum-|>": (inherit: "stealth", angle: 30deg, stealth: 0, size: 14, fill: none),
  "plum->": (inherit: "straight", sharpness: 30deg, size: 14),
  "plum-x": (inherit: "x", size: 7),
  "plum-o": (inherit: "stealth", angle: 30deg, stealth: -1, size: 10, fill: none),
  "plum-*": (inherit: "plum-o", fill: auto),
)

/// addd plum-specific marks to Fletcher
///
/// -> content
#let add-marks() = {
  import "imports.typ": fletcher

  fletcher.MARKS.update(marks => (: ..marks, ..MARKS))
}

/// A multiplicity specifier on one end of an association.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, association-end-multiplicity
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(association-end-multiplicity,
///   it => { set text(gray); it })
/// #plum.plum(```
/// #[pos(0, 0)] class Foo
/// #[pos(1, 0)] class Bar
/// Foo (x [1]) <-- Bar
/// ```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.association-end-multiplicity)
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
    e.field("multiplicity", content, required: true, doc: "the multiplicity of the association end"),
  ),
)

/// A role specifier on one end of an association.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, association-end-role
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(association-end-role,
///   it => { set text(weight: "bold"); it })
/// #plum.plum(```
/// #[pos(0, 0)] class Foo
/// #[pos(1, 0)] class Bar
/// Foo (x [1]) <-- Bar
/// ```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.association-end-role)
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
    e.field("name", content, required: true, doc: "the role name of the association end"),
    e.field("visibility", content, default: none, doc: "the visibility of the association"),
    e.field("static", bool, default: false, doc: "whether this is a static association (technically invalid)"),
    e.field("type", e.types.option(content), default: none, doc: "the data type of the association"),
    e.field("modifiers", array, default: (), doc: "modifiers such as readOnly or invariants"),
  ),
)

/// An edge between two @@classifier;s; can represent associations, dependencies, etc.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, edge
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.set_(edge, stroke: blue+0.5pt)
/// #plum.plum(```
/// #[pos(0, 0)] class Foo
/// #[pos(1, 0)] class Bar
/// Foo <|-- Bar
/// ```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.edge)
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
    e.field("a", e.types.union(str, label), required: true, doc: "the ID (or name) of the first edge end"),
    e.field("b", e.types.union(str, label), required: true, doc: "the ID (or name) of the second edge end"),
    e.field("kind", dictionary, required: true, doc: "a dictionary with more information on the edge; at minimum, the type must be defined"),
    e.field("via", array, default: (), doc: "an array of coordinates through which the edge should go (instead of a straight line)"),
    e.field("bend", e.types.option(float), default: none, doc: "an angle by which to bend the edge (instead of a straight line)"),

    // styling
    e.field("stroke", e.types.option(stroke), default: 0.3pt, doc: "the stroke to use for the edge"),
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

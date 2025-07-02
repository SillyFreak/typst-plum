#import "imports.typ": elembic as e

#let stereotypes = e.element.declare(
  "stereotypes",
  prefix: "@preview/plum,v1",

  template: it => {
    set text(0.8em)
    it
  },

  display: it => {
    let (children,) = it

    [«#children.join[, ]»]
  },

  fields: (
    e.field("children", array, required: true),
  ),
)

#let name = e.element.declare(
  "name",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    let (body,) = it

    body
  },

  fields: (
    e.field("body", content, required: true),
  ),
)

#let member = e.element.declare(
  "member",
  prefix: "@preview/plum,v1",

  template: it => {
    set grid(
      align: (top+end, top+start),
      gutter: 0pt,
      inset: 0pt,
    )
    it
  },

  display: it => {
    let (body, visibility, static, abstract, visibility-width) = it

    set text(style: "italic") if abstract
    show: if static { underline } else { it => it }

    grid(
      columns: (visibility-width, auto),
      align: top,
      [#visibility~],
      body,
    )
  },

  fields: (
    e.field("body", content, required: true),
    e.field("visibility", content, default: none),
    e.field("static", bool, default: false),
    e.field("abstract", bool, default: false),

    e.field("visibility-width", length, named: true, internal: true),
  ),
)

#let divider() = grid.hline()

#let attribute = e.element.declare(
  "attribute",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    let (name, type, multiplicity, modifiers) = it

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

    name
    if type != none [: #type]
    if multiplicity != none [ \[#multiplicity\]]
    if modifiers != () [ {#modifiers.map(modifier).join[, ]}]
  },

  fields: (
    e.field("name", content, required: true),
    e.field("type", e.types.option(content), default: none),
    e.field("multiplicity", e.types.option(content), default: none),
    e.field("modifiers", array, default: ()),
  ),
)

#let operation = e.element.declare(
  "operation",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    let (name, parameters, return-type) = it

    let parameter(
      name: none,
      type: none,
    ) = {
      assert.ne(name, none, message: "name is required")

      name
      if type != none [: #type]
    }

    name
    [(#parameters.map(p => parameter(..p)).join[, ])]
    if return-type != none [: #return-type]
  },

  fields: (
    e.field("name", content, required: true),
    e.field("parameters", array, default: ()),
    e.field("return-type", e.types.option(content), default: none),
  ),
)

#let classifier = e.element.declare(
  "classifier",
  doc: "A class, interface or simiar item",
  prefix: "@preview/plum,v1",

  template: it => {
    let (kind, abstract) = (kind: "class", abstract: auto, ..e.fields(it))

    if abstract == auto { abstract = kind == "interface" }

    set grid(
      align: start,
      inset: 0.3em,
    )

    show e.selector(name): set text(style: "italic") if abstract

    it
  },

  display: it => {
    let (stroke, fill, radius) = it
    show: block.with(stroke: stroke, fill: fill, radius: radius)
    set grid.hline(stroke: stroke)

    show: e.set_(member, visibility-width: it.visibility-width)

    let title = {
      let _stereotypes = it.stereotypes
      if it.kind != "class" {
        _stereotypes.insert(0, it.kind)
      }
      if _stereotypes.len() > 0 {
        stereotypes(_stereotypes)
        linebreak()
      }
      name(it.name)
    }

    let members = it.members
    let has-divider = members.any(m => m == divider())
    if not has-divider {
      // TODO divide into two sections for attributes and operations
    }

    // add an initial divider for under the title
    members.insert(0, divider())
    // check for adjacent dividers (or a trailing divider)
    for i in range(members.len() - 1, -1, step: -1) {
      if  members.at(i) == divider() and (i == members.len() - 1 or members.at(i + 1) == divider()) {
        if it.empty-sections {
          // insert a placeholder row
          members.insert(i + 1, v(-1pt))
        } else {
          _ = members.remove(i)
        }
      }
    }

    grid(
      columns: 1,

      grid.cell(align: center, title),
      ..members,
    )
  },

  fields: (
    e.field("name", content, required: true),
    e.field("id", e.types.union(auto, str, label), default: auto),
    e.field("position", e.types.smart(e.types.any), default: auto),
    e.field("abstract", e.types.smart(bool), default: auto),
    e.field("final", bool, default: false),
    e.field("stereotypes", array, default: ()),
    e.field("kind", str, default: "class"),
    e.field("members", array, default: ()),

    // styling
    e.field("visibility-width", length, default: 0.8em),
    e.field("empty-sections", bool, default: true),

    e.field("stroke", e.types.option(stroke), default: 0.5pt),
    e.field("fill", e.types.union(none, color, gradient, tiling), default: none),
    e.field("radius", e.types.union(relative, dictionary), default: 2pt),
  )
)

#let to-fletcher(it, get) = {
  import "imports.typ": fletcher

  let (name, id, position) = (: ..get(classifier), ..e.fields(it))
  if id == auto {
    assert(type(name) == content and name.func() == text)
    id = name.text
  }
  if type(id) == str { id = label(id) }

  assert.ne(position, auto, message: "automatic positioning is currently not supported. add #[pos(x, y)] to each classifier")

  fletcher.node(position, it, name: id, shape: "rect")
}

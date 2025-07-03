#import "imports.typ": elembic as e

/// The element that shows stereotypes above a classifiers name.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, stereotypes
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(stereotypes, it => {
///   set text(gray.darken(40%)); it
/// })
/// #plum.plum("#[pos(0, 0)] interface Foo")
/// ````))
///
/// #elem-fields(plum.elembic, plum.stereotypes)
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
    e.field("children", array, required: true, doc: "the stereotypes of the classifier"),
  ),
)

/// The element that shows a classifiers name.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, name
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(name, it => {
///   set text(weight: "bold"); it
/// })
/// #plum.plum("#[pos(0, 0)] interface Foo")
/// ````))
///
/// #elem-fields(plum.elembic, plum.name)
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
    e.field("body", content, required: true, doc: "the name of the classifier"),
  ),
)

/// A member entry of a classifier. Usually, this will contain an @@attribute or @@operation.
///
/// The member element shows the visibility modifier and styles the text according to the `static`
/// and `abstract` fields.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, member
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(member, it => {
///   set text(weight: "bold"); it
/// })
/// #plum.plum(```
/// #[pos(0, 0)] class Foo {
///   - static x: int
///   + abstract y()
/// }```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.member)
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
    e.field("body", content, required: true, doc: "usually an attribute or operation"),
    e.field("visibility", content, default: none, doc: "the visibility modifier"),
    e.field("static", bool, default: false, doc: "the member is underlined if true"),
    e.field("abstract", bool, default: false, doc: "the member is italicized if true"),

    e.field("visibility-width", length, named: true, internal: true, doc: "the width of the visibility modifier for alignment"),
  ),
)

/// A divider separating sections in a classifier; usually between @@attribute;s and @@operation;s.
///
/// -> content
#let divider() = grid.hline()

/// An attribute. Usually, this will be contained in a @@member.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, attribute
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(attribute.with(name: [y]), it=>{
///   rect(width: 5cm) // fill in the blanks
/// })
/// #plum.plum(```
/// #[pos(0, 0)] class Foo {
///   - x: int [1] {readOnly}
///   - y: int
/// }```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.attribute)
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
    e.field("name", content, required: true, doc: "the name of the attribute"),
    e.field("type", e.types.option(content), default: none, doc: "the data type of the attribute"),
    e.field("multiplicity", e.types.option(content), default: none, doc: "how many values the attribute contains"),
    e.field("modifiers", array, default: (), doc: "modifiers such as readOnly or invariants"),
  ),
)

/// An operation. Usually, this will be contained in a @@member.
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, operation
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.show_(operation.with(name: [y]), it=>{
///   rect(width: 5cm) // fill in the blanks
/// })
/// #plum.plum(```
/// #[pos(0, 0)] class Foo {
///   + x(): int
///   + y(): int
/// }```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.operation)
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
    e.field("name", content, required: true, doc: "the name of the operation"),
    e.field("parameters", array, default: (), doc: "the parameters of the operation; dictionaries consisting of name and optional type"),
    e.field("return-type", e.types.option(content), default: none, doc: "the return type of the operation"),
  ),
)

/// A class, interface or similar element in an UML class diagram
///
/// #block(breakable: false, example(mode: "markup", dir: ltr, ratio: 1.5, ````typ
/// >>> #import plum: elembic as e, diagram, classifier
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
/// #show: e.cond-set(classifier.with(name: [Foo]),
///   stroke: red, fill: gray.lighten(50%))
/// #show: e.cond-set(classifier.with(name: [Bar]),
///   empty-sections: false)
/// #plum.plum(```
/// #[pos(0, 0)] class Foo
/// #[pos(1, 0)] class Bar
/// ```)
/// ````))
///
/// #elem-fields(plum.elembic, plum.classifier)
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
    e.field("name", content, required: true, doc: "the name of the classifier"),
    e.field("id", e.types.union(auto, str, label), default: auto, doc: "an ID for the classifier, e.g. as a shorthand for a long name"),
    e.field("position", e.types.smart(e.types.any), default: auto, doc: "the position of the classifier in the diagram; auto can currently not be rendered!"),
    e.field("abstract", e.types.smart(bool), default: auto, doc: "whether the classifier is abstract; interfaces are abstract by default"),
    e.field("final", bool, default: false, doc: "whether the classifier is final"),
    e.field("stereotypes", array, default: (), doc: "the classifier's stereotypes; interface is added automatically"),
    e.field("kind", str, default: "class", doc: "the classifier's kind, e.g. class, interface, exception"),
    e.field("members", array, default: (), doc: "the members of the classifier; usually member instances and dividers"),

    // styling
    e.field("visibility-width", length, default: 0.8em, doc: "how much space members should reserve on the left for visibility modifiers"),
    e.field("empty-sections", bool, default: true, doc: "whether to show or collapse empty sections, i.e. if there are no attributes or operations"),

    e.field("stroke", e.types.option(stroke), default: 0.5pt, doc: "the stroke for the classifier border and dividers"),
    e.field("fill", e.types.union(none, color, gradient, tiling), default: none, doc: "the fill for the classifier"),
    e.field("radius", e.types.union(relative, dictionary), default: 2pt, doc: "the border radius for the classifier"),
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

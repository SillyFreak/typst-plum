#let classifier(
  name,
  pos: auto,
  id: auto,
  abstract: auto,
  final: false,
  stereotypes: (),
  kind: "class",
  attributes: auto,
  operations: (),
  ..args
) = {
  import "imports.typ": fletcher.node

  assert.ne(pos, auto, message: "automatic positioning is currently not supported. add #[pos(x, y)] to each classifier")

  if id == auto { id = name }
  if type(id) == str { id = label(id) }
  if abstract == auto { abstract = kind == "interface" }
  if attributes == auto {
    attributes = if kind == "interface" { none } else { () }
  }

  let title = {
    set align(center)
    if kind != "class" {
      stereotypes.insert(0, kind)
    }
    if stereotypes.len() > 0 {
      set text(0.8em)
      [«#stereotypes.join[, ]»]
      linebreak()
    }
    // set text(weight: "bold")
    set text(style: "italic") if abstract
    name
  }
  let attributes = if attributes != none {
    set align(start)
    if attributes.len() > 0 {
      attributes.map(attribute => {
        if "visibility" in attribute [#attribute.visibility ]
        attribute.name
        if "type" in attribute [: #attribute.type]
      }).join(linebreak())
    } else {
      v(-4pt)
    }
  }
  let operations = if operations != none {
    set align(start)
    if operations.len() > 0 {
      operations.join(linebreak())
    } else {
      v(-4pt)
    }
  }

  let body = {
    set grid(inset: (x: 0.4em, y: 0.4em))
    set grid.hline(stroke: 0.5pt)
    show: block.with(stroke: 0.5pt, radius: 2pt)

    grid(
      title,
      ..if attributes != none {(grid.hline(), attributes)},
      ..if operations != none {(grid.hline(), operations)},
    )
  }

  node(pos, body, name: id, shape: "rect", ..args)
}

#let attribute(
  visibility: none,
  name: none,
  type: none,
  multiplicity: none,
) = {
  assert.ne(name, none, message: "name is required")

  (visibility, {
    name
    if type != none [: #type]
    if multiplicity != none [ \[#multiplicity\]]
  })
}

#let operation(
  visibility: none,
  name: none,
  parameters: (),
  return-type: none,
) = {
  let parameter(
    name: none,
    type: none,
  ) = {
    assert.ne(name, none, message: "name is required")

    name
    if type != none [: #type]
  }

  assert.ne(name, none, message: "name is required")

  (visibility, {
    name
    [(#parameters.map(p => parameter(..p)).join[, ])]
    if return-type != none [: #return-type]
  })
}

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
    if attributes.len() > 0 {
      attributes.map(a => attribute(..a)).join()
    } else {
      (grid.cell(colspan: 2, v(-1pt)),)
    }
  }
  let operations = if operations != none {
    if operations.len() > 0 {
      operations.map(o => operation(..o)).join()
    } else {
      (grid.cell(colspan: 2, v(-1pt)),)
    }
  }

  let body = {
    set grid.hline(stroke: 0.5pt)

    grid(
      columns: 2,
      column-gutter: -0.5em,
      align: (center, start),
      inset: 0.3em,

      grid.cell(colspan: 2, title),
      ..if attributes != none {(grid.hline(), ..attributes)},
      ..if operations != none {(grid.hline(), ..operations)},
    )
  }

  node(pos, body, name: id, shape: "rect", stroke: 0.5pt, corner-radius: 2pt, ..args)
}

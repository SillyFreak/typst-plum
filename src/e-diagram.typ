#import "imports.typ": elembic as e

#let diagram = e.element.declare(
  "diagram",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    import "imports.typ": fletcher

    fletcher.diagram(
      node-inset: 0pt,
      axes: (ltr, ttb),
      {
        for x in it.classifiers {
          let (name, id, position) = (id: auto, position: auto, ..e.fields(x))
          if id == auto {
            assert(type(name) == content and name.func() == text)
            id = name.text
          }
          if type(id) == str { id = label(id) }

          assert.ne(position, auto, message: "automatic positioning is currently not supported. add #[pos(x, y)] to each classifier")

          fletcher.node(position, x, name: id, shape: "rect")
        }
        for (a, b, kind, ..args) in it.edges {
          edge.edge(a, b, kind, ..args)
        }
      }
    )
  },

  fields: (
    e.field("classifiers", array, default: ()),
    e.field("edges", array, default: ()),
  ),
)

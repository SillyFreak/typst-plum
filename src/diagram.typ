#import "imports.typ": elembic as e

#let diagram = e.element.declare(
  "diagram",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => e.get(get => {
    import "imports.typ": fletcher
    import "classifier.typ" as classifier
    import "edge.typ" as edge

    fletcher.diagram(
      node-inset: 0pt,
      axes: (ltr, ttb),
      {
        for x in it.classifiers {
          classifier.to-fletcher(x, get)
        }
        for x in it.edges {
          edge.to-fletcher(x, get)
        }
      }
    )
  }),

  fields: (
    e.field("classifiers", array, default: ()),
    e.field("edges", array, default: ()),
  ),
)

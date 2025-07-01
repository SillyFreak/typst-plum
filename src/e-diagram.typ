#import "imports.typ": elembic as e

#let diagram = e.element.declare(
  "diagram",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    import "imports.typ": fletcher.diagram
    import "e-classifier.typ" as classifier

    diagram(
      node-inset: 0pt,
      axes: (ltr, ttb),
      {
        for x in it.classifiers {
          classifier.to-fletcher(x)
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

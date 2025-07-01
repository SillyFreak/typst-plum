#import "imports.typ": elembic as e

#let diagram = e.element.declare(
  "diagram",
  prefix: "@preview/plum,v1",

  // template: it => {
  //   it
  // },

  display: it => {
    import "imports.typ": fletcher.diagram
    import "classifier.typ" as classifier
    import "edge.typ" as edge

    diagram(
      node-inset: 0pt,
      axes: (ltr, ttb),
      {
        for x in it.classifiers {
          classifier.to-fletcher(x)
        }
        for x in it.edges {
          edge.to-fletcher(x)
        }
      }
    )
  },

  fields: (
    e.field("classifiers", array, default: ()),
    e.field("edges", array, default: ()),
  ),
)

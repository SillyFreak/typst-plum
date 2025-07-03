#import "imports.typ": elembic as e

/// A custom element representing a plum diagram
///
/// #elem-fields(plum.elembic, plum.diagram)
#let diagram = e.element.declare(
  "diagram",
  doc: "A custom element representing a plum diagram",
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
    e.field("classifiers", array, default: (), doc: "the classes, interfaces, etc. in the diagram"),
    e.field("edges", array, default: (), doc: "the dependencies, associations, etc. in the diagram"),
  ),
)

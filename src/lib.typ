#import "classifier.typ"
#import "edge.typ" as edge: MARKS, add-marks
#import "package.typ"

#import "imports.typ": elembic
#import "e-classifier.typ"

#let _p = plugin("parser.wasm")

/// Parses a diagram via a WASM plugin.
///
/// #example(mode: "markup", dir: ttb, ```typ
/// #plum.parse("class Foo")
/// ```)
/// #example(mode: "markup", dir: ttb, ````typ
/// #plum.parse(```
/// interface Bar
/// exception Baz
/// ```)
/// ````)
///
/// -> dict
#let parse(
  /// the expression to parse; may be a `raw` element
  /// -> str | content
  diagram,
) = {
  // Typst 0.13: `cbor.decode` is deprecated, directly pass bytes to `cbor` instead
  let decode = if sys.version < version(0, 13, 0) { cbor.decode } else { cbor }

  if type(diagram) == content and diagram.func() == raw {
    diagram = diagram.text
  }
  decode(_p.parse(cbor.encode(diagram)))
}

/// Parses and processes a diagram.
///
/// #example(mode: "markup", dir: ttb, ````typ
/// #plum.plum(```plum
///   #[pos(0, 0)]
///   interface Bar
///   #[pos(1, 0)]
///   exception Baz
/// ```)
/// ````)
///
/// -> content
#let plum(
  /// the expression to parse; may be a `raw` element
  /// -> str | content
  diagram,
) = {
  import "imports.typ": fletcher

  set text(font: ("FreeSans",), size: 0.8em)

  let diagram = parse(diagram)

  fletcher.diagram(
    node-inset: 0pt,
    axes: (ltr, ttb),
    {
      for (name, ..args) in diagram.classifiers {
        classifier.classifier(name, ..args)
      }
      for (a, b, kind, ..args) in diagram.edges {
        edge.edge(a, b, kind, ..args)
      }
    }
  )
}

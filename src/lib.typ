#import "classifier.typ"

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
/// - diagram (str): the expression to parse
/// -> dict
#let parse(diagram) = {
  if type(diagram) == content and diagram.func() == raw {
    diagram = diagram.text
  }
  cbor.decode(_p.parse(cbor.encode(diagram)))
}

/// Parses and processes a diagram.
///
/// #example(mode: "markup", dir: ttb, ````typ
/// #plum.plum(
///   ```
///   interface Bar
///   exception Baz
///   ```, (
///     Bar: (0, 0),
///     Baz: (1, 0),
///   )
/// )
/// ````)
///
/// - diagram (str): the expression to parse
/// - pos (dict): positions of classes in the diagram
/// -> dict
#let plum(diagram, pos) = {
  import "imports.typ": fletcher

  set text(font: ("FreeSans",), size: 0.8em)

  let diagram = parse(diagram)

  fletcher.diagram(
    node-inset: 0pt,
    axes: (ltr, ttb),
    {
      for (name, ..args) in diagram.classifiers {
        classifier.classifier(pos.at(name), name, ..args)
      }
    }
  )
}

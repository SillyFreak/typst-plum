#let _p = plugin("parser.wasm")

/// Parses an expression via a WASM plugin.
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

#import "classifier.typ"
#import "edge.typ" as edge: MARKS, add-marks
#import "package.typ"

#import "imports.typ": elembic
#import "classifier.typ"
#import "diagram.typ"
#import "edge.typ"

#let _p = plugin("parser.wasm")
#let _diagram = diagram

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
  set text(font: ("FreeSans",), size: 0.8em)

  let diagram = parse(diagram)

  let split-dict(dict, ..keys) = {
    let keys = keys.pos()
    let split = (:)
    for key in keys {
      if key in dict {
        split.insert(key, dict.remove(key))
      }
    }
    (split, dict)
  }

  _diagram.diagram(
    classifiers: diagram.classifiers.map(((name, ..args)) => {
      let ((pos: position, ..members), args) = split-dict(args, "pos", "attributes", "operations")
      let members = (
        ..if "attributes" in members {
          members.attributes.map(((name, ..args)) => {
            let (member-args, attribute-args) = split-dict(args, "visibility", "static")
            classifier.member(..member-args, classifier.attribute(name, ..attribute-args))
          })
        },
        classifier.divider(),
        ..if "operations" in members {
          members.operations.map(((name, ..args)) => {
            let (member-args, operation-args) = split-dict(args, "visibility", "static", "abstract")
            classifier.member(..member-args, classifier.operation(name, ..operation-args))
          })
        },
      )
      classifier.classifier(name, position: position, members: members, ..args)
    }),
    edges: diagram.edges.map(((a, b, kind, ..args)) => edge.edge(a, b, kind, ..args)),
  )
}

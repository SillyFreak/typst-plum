#import "classifier.typ"
#import "edge.typ" as edge: MARKS, add-marks
#import "package.typ"

#import "imports.typ": elembic
#import "classifier.typ"
#import "diagram.typ"
#import "edge.typ"

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
  src,
) = {
  // Typst 0.13: `cbor.decode` is deprecated, directly pass bytes to `cbor` instead
  let decode = if sys.version < version(0, 13, 0) { cbor.decode } else { cbor }

  if type(src) == content and src.func() == raw {
    src = src.text
  }
  decode(_p.parse(cbor.encode(src)))
}

/// Parses and processes a diagram.
///
/// #example(mode: "markup", dir: ttb, ````typ
/// >>> #import plum: elembic as e, diagram.diagram
/// >>> #show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
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
  src,
) = {
  let src = parse(src)

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

  diagram.diagram(
    classifiers: src.classifiers.map(((name, ..args)) => {
      let (members, args) = split-dict(args, "attributes", "operations")
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
      classifier.classifier(name, members: members, ..args)
    }),
    edges: src.edges.map(((a, b, kind, ..args)) => {
      if kind.type == "association" {
        let map-role(role) = {
          if role == none { return none }
          let (name, multiplicity, ..role) = (multiplicity: none, ..role)
          let result = (
            role: edge.association-end-role(name, ..role)
          )
          if multiplicity != none {
            result.multiplicity = edge.association-end-multiplicity(multiplicity)
          }
          result
        }
        kind.a += map-role(kind.a.remove("role", default: none))
        kind.b += map-role(kind.b.remove("role", default: none))
      }
      edge.edge(a, b, kind, ..args)
    }),
  )
}

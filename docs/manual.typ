#import "template.typ" as template: *
#import "/src/lib.typ" as plum

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: "Plum",
  subtitle: [
    _Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML.
  ],
  date: none,
  // date: datetime(year: ..., month: ..., day: ...),

  // logo: rect(width: 5cm, height: 5cm),
  // abstract: [
  //   A PACKAGE for something
  // ],

  scope: (plum: plum, style: man-style, elem-fields: elem-fields),
)

#codly.codly(smart-skip: (first: false, last: false, rest: true))

= Introduction

_Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML. It is currently in early stages; things _will_ still change.

Plum provides the #ref-fn("parse()") and #ref-fn("plum()") functions as entry points, and supports styling through #link("https://pgbiel.github.io/elembic/")[Elembic]:

#let diagram-src = ```plum
#[pos(1, 0)]
interface Expression as Expr {
  + evaluate(): double
}

#[pos(0, 0)]
abstract class Unary

#[pos(0, 1)]
class Negate {
  + evaluate(): double
}

#[pos(1, 1)]
class Number {
  - value: double {readOnly}
  + evaluate(): double
}

#[pos(2, 0)]
class Binary {
  + evaluate(): double
}

#[pos(2, 1)]
interface BinaryOp {
  + evaluate(a: double, b: double): double
}

#[bend(20deg)]
Unary --|> Expr
#[bend(20deg)]
Expr (# expr [1]) <--o Unary

Expr <|.. Number

#[bend(-20deg)]
Binary --|> Expr
#[bend(20deg)]
Binary o--> (- exprs [2]) Expr

Unary <|-- Negate
Binary o--> (- operator [1]) BinaryOp
```
#let render-src = ```typc
import plum: elembic as e, diagram, edge, classifier

// let fletcher know about the marks used in Plum UML's edges
plum.add-marks()
// do some general styling
show: e.show_(diagram, it => { set text(0.8em, font: ("FreeSans",)); it })
show: e.set_(edge, stroke: 0.5pt)

// let diagram-src = ...
show: e.cond-set(
  classifier.with(name: [Expression]),
  fill: color.olive.lighten(50%),
)
plum.plum(diagram-src)
```
#align(center, {
  eval(render-src.text, scope: (plum: plum, diagram-src: diagram-src))
})

The example above shows a possible model for mathematical expressions. If you're familiar with tools like PlantUML or Mermaid, the mode of creating diagrams will be familiar:

#codly.codly(ranges: ((14, 28), (40, 40)))
#diagram-src

One thing Plum is currently lacking is a layout algorithm, so coordinates need to be specified manually. This should change in the future.

The code for rendering the diagram looks like this:

#codly.codly(ranges: ((1, 9), (14, 14)))
#render-src

The central interface `Expression` is highlighted; note that the definition of the diagram and the styling is separated:

#grid(
  columns: (2fr, 2fr),
  {
    codly.codly(range: (1, 4))
    diagram-src
  },
  {
    codly.codly(range: (10, 13))
    render-src
  },
)

= Module reference

#module(
  read("/src/lib.typ"),
  name: "plum",
  label-prefix: none,
)

#module(
  read("/src/diagram.typ"),
  name: "diagram",
  label-prefix: none,
)

#module(
  read("/src/classifier.typ"),
  name: "classifier",
  label-prefix: none,
)

#module(
  read("/src/edge.typ"),
  name: "edge",
  label-prefix: none,
)

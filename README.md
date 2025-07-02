# Plum

_Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML.

## Getting Started

To add this package to your project, use this:

````typ
#import "@preview/plum:0.0.1"

#let diagram = ```
#[pos(0, 1)]
class Foo as X {
  - attr
  attr2
}

#[pos(1, 0)]
interface Bar {
  + attr
}

#[pos(2, 1)]
abstract class Baz {
  # bars
}

#[bend(45deg)]
X ..|> Bar
#[via((1, 0.4), (2, 0.4))]
Bar <--x-* Baz
```

#import plum: elembic as e, classifier.classifier
#show: e.cond-set(classifier.with(name: [Foo]), fill: gray)

#plum.plum(diagram)
````

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

## Usage

See the [manual](docs/manual.pdf) for details.

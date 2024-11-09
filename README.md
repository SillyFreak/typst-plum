# Plum

_Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML.

## Getting Started

To add this package to your project, use this:

````typ
#import "@preview/plum:0.0.1"

#let diagram = ```
#[pos(0, 0)]
class Foo

#[pos(1, 0)]
interface Bar
```

#plum.plum(diagram)
````

![Example](./thumbnail.png)

## Usage

See the [manual](docs/manual.pdf) for details.

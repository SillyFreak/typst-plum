# Plum

_Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML.

## Getting Started

To add this package to your project, use this:

```typ
#import "@preview/plum:0.0.1": *

#let expr = "2 * (2 + x)"

#eval(mode: "math", expr)

#plum.parse(expr)

#plum.eval(expr, x: 3)
```

![Example](./thumbnail.png)

## Usage

See the [manual](docs/manual.pdf) for details.

#import "/src/lib.typ" as plum
#import "@preview/crudo:0.1.1"

#set document(date: none)
#set page(width: 10cm, height: auto, margin: 5mm)
#set text(0.85em)

#plum.add-marks()

#let diagram = ```
#[pos(0, 1)]
class Foo as X {
  - attr
  attr2: X
}

#[pos(1, 0)]
interface Bar

#[pos(2, 1)]
abstract class Baz {
  # bars: "List<Y>"
}

X ..|> Bar
// X ..> Bar
Bar <--x-o Baz
```

#grid(
  columns: (1fr, 1fr),
  crudo.lines(diagram, "-8"),
  crudo.lines(diagram, "10-"),
)

// #plum.parse(diagram)

#align(center, plum.plum(diagram))

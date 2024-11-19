#import "/src/lib.typ" as plum
#import "@preview/crudo:0.1.1"

#set document(date: none)
#set page(width: 11cm, height: auto, margin: 5mm)
#set text(0.85em)

#plum.add-marks()

#let diagram = ```
#[pos(0, 1)]
class Foo as X {
  - attr [1]
  attr2: X
  + op()
}

#[pos(2, 1)]
abstract class Baz {
  + op(x: X, y: Y): Z
}

#[pos(1, 0)]
interface Bar

#[bend(45deg)]
X ..|> Bar
#[via((1, 0.4), (2, 0.4))]
Bar (# bars: "List<Bar>" [0..*]) <--x-o Baz
```

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  crudo.lines(diagram, "-12"),
  crudo.lines(diagram, "14-"),
)

// #plum.parse(diagram)

#align(center, plum.plum(diagram))

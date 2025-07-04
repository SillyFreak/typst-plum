#import "/src/lib.typ" as plum
#import "@preview/crudo:0.1.1"

#set page(height: auto, margin: 5mm, fill: none)

// style thumbnail for light and dark theme
#let theme = sys.inputs.at("theme", default: "light")
#set text(white) if theme == "dark"

#plum.add-marks()

#let diagram-src = ```
#[pos(0, 1)]
class Foo as X {
  - static attr [1] {readOnly}
  attr2: X {"attr != null"}
  + op()
}

#[pos(2, 1)]
abstract class Baz {
  + abstract op(x: X, y: Y): Z
}

#[pos(1, 0)]
interface Bar

#[bend(45deg)]
X ..|> Bar
#[via((1, 0.4), (2, 0.4))]
Bar (# bars: "List<Bar>" [0..*]) <--x-* Baz
```

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  crudo.lines(diagram-src, "-11"),
  crudo.lines(diagram-src, "13-"),
)

// #plum.parse(diagram-src)

#import plum: elembic as e, diagram, classifier, edge

#show: it => {
  if theme != "dark" { return it }
  show: e.set_(classifier, stroke: white)
  show: e.set_(edge, stroke: white)
  it
}

#show: e.show_(diagram, it => { set text(font: ("FreeSans",)); it })
// #show: e.set_(classifier, empty-sections: false)
#show: e.cond-set(classifier.with(name: [Foo]), fill: if theme == "dark" { gray.darken(50%) } else { gray.lighten(50%) })

#align(center, plum.plum(diagram-src))

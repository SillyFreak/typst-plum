#import "/src/lib.typ" as plum

#set document(date: none)
#set page(width: 10cm, height: auto, margin: 5mm)
#set text(0.85em)

#plum.add-marks()

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

X ..|> Bar
// X ..> Bar
Bar <--x-o Baz
```

#diagram

// #plum.parse(diagram)

#plum.plum(diagram)

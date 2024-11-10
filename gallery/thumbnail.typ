#import "/src/lib.typ" as plum

#set document(date: none)
#set page(width: 10cm, height: auto, margin: 5mm)
#set text(0.85em)

#let diagram = ```
#[pos(0, 0)]
class Foo as X {
  - attr
  attr2
}

#[pos(1, 0)]
interface Bar {
  + attr
}
```

#diagram

// #plum.parse(diagram)

#plum.plum(diagram)

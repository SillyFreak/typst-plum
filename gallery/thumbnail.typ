#import "/src/lib.typ" as plum

#set document(date: none)
#set page(width: 10cm, height: auto, margin: 5mm)
#set text(0.85em)

#let diagram = ```
#[pos(0, 0)]
class Foo

#[pos(1, 0)]
interface Bar
```

#diagram

// #plum.parse(diagram)

#plum.plum(diagram)

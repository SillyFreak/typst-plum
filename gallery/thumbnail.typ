#import "/src/lib.typ" as plum

#set document(date: none)
#set page(width: 10cm, height: auto, margin: 5mm)
#set text(0.85em)

#let diagram = ```
class Foo
interface Bar
```

#diagram

#plum.parse(diagram)

#import "/src/lib.typ" as plum

#set page(width: auto, height: auto, margin: 5mm)

#plum.edge.add-marks()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A ..> B
#[bend(-30deg)]
B <.. A
//A .. B
#[bend(-30deg)]
A <.. B
#[bend(60deg)]
B ..> A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A --|> B
#[bend(-30deg)]
B <|-- A
#[bend(-30deg)]
A <|-- B
#[bend(60deg)]
B --|> A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A ..|> B
#[bend(-30deg)]
B <|.. A
//A .. B
#[bend(-30deg)]
A <|.. B
#[bend(60deg)]
B ..|> A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A --> B
#[bend(-30deg)]
B <-- A
A -- B
#[bend(-30deg)]
A <-- B
#[bend(60deg)]
B --> A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A -x--> B
#[bend(-30deg)]
B <--x- A
#[bend(-30deg)]
A <--x- B
#[bend(60deg)]
B -x--> A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A -x-- B
#[bend(-40deg)]
B --x- A
#[bend(15deg)]
A -x--x- B
#[bend(15deg)]
B -x--x- A
#[bend(-40deg)]
A --x- B
#[bend(60deg)]
B -x-- A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A o-x-- B
#[bend(-40deg)]
B --x-o A
#[bend(15deg)]
A o-x--x-* B
#[bend(15deg)]
B *-x--x-o A
#[bend(-40deg)]
A --x-* B
#[bend(60deg)]
B *-x-- A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A o-x--> B
#[bend(-40deg)]
B <--x-o A
#[bend(15deg)]
A o-x--> B
#[bend(15deg)]
B *-x--> A
#[bend(-40deg)]
A <--x-* B
#[bend(60deg)]
B *-x--> A
```)

#pagebreak()

#plum.plum(```plum
#[pos(0, 0)]
class A
#[pos(3, 0)]
class B

#[bend(60deg)]
A o--> B
#[bend(-40deg)]
B <--o A
#[bend(15deg)]
A o--> B
#[bend(15deg)]
B *--> A
#[bend(-40deg)]
A <--* B
#[bend(60deg)]
B *--> A
```)

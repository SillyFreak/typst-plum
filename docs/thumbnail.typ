#import "/src/lib.typ" as plum
#import "@preview/crudo:0.1.1"

#set page(height: auto, margin: 5mm, /*fill: none*/)

// style thumbnail for light and dark theme
#let theme = sys.inputs.at("theme", default: "light")
#set text(white) if theme == "dark"

#set text(0.85em)

#plum.add-marks()

#let diagram = ```
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
Bar (# bars: "List<Bar>" [0..*]) <--x-o Baz
```

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  crudo.lines(diagram, "-11"),
  crudo.lines(diagram, "13-"),
)

// #plum.parse(diagram)

#align(center, plum.plum(diagram))

#import plum.elembic as e
#import plum.e-classifier: classifier, name, member, divider, attribute, operation

#show: e.cond-set(classifier.with(name: [Foo]), fill: gray)

#[
  #show: e.show_(classifier, it => { set text(font: ("FreeSans",), size: 0.8em); it })
  // #show: e.set_(classifier, visibility-width: 2em)

  #classifier(
    "Foo",
    kind: "interface",
    // empty-sections: false,
    members: (
      member(visibility: "+", static: true, attribute(
        multiplicity: [1],
        modifiers: ("readOnly",),
        "attr",
      )),
      divider(),
      member(visibility: "-", abstract: true, operation(
        "op",
        return-type: "bool",
        parameters: ((name: "b", type: "Bar"),),
      )),
      member[#h(2cm)#v(2cm)],
    ),
  )
]

#[
  #let (classifiers, edges) = plum.parse(diagram)
  #import plum.e-diagram: diagram

  #show: e.show_(diagram, it => { set text(font: ("FreeSans",), size: 0.8em); it })

  #align(center, diagram(
    classifiers: (
      classifier("Foo", id: <X>, position: (0, 1)),
      classifier("Baz", position: (2, 1)),
      classifier("Bar", position: (1, 0)),
    ),
    edges: edges,
  ))
]

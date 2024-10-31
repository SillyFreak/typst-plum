#import "/src/lib.typ" as plum

#set document(date: none)
#set page(width: 10cm, height: auto, margin: 5mm)
#set text(0.85em)

#let expr = "2 * (2 + x)"

#grid(
  columns: 3,
  column-gutter: 2pt,
  row-gutter: 8pt,

  eval(mode: "math", expr),
  $arrow.double.long$,
  [#plum.parse(expr)],

  eval(mode: "math", expr),
  $arrow.double.long^(x=3)$,
  [#plum.eval(expr, x: 3)],
)

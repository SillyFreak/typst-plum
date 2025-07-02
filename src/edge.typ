#let MARKS = (
  "plum-|>": (inherit: "stealth", angle: 30deg, stealth: 0, size: 14, fill: none),
  "plum->": (inherit: "straight", sharpness: 30deg, size: 14),
  "plum-x": (inherit: "x", size: 7),
  "plum-o": (inherit: "stealth", angle: 30deg, stealth: -1, size: 10, fill: white),
  "plum-*": (inherit: "plum-o", fill: black),
)

#let add-marks() = {
  import "imports.typ": fletcher

  fletcher.MARKS.update(marks => (: ..marks, ..MARKS))
}

// #let assoc = edge.with(dash: none)
// #let assoc = edge.with(dash: none, marks: (
// 	none,
// 		(kind: "vee", sharpness: 30deg, size: 12),
// ))
#let edge(
  a,
  b,
  kind,
  via: (),
  bend: none,
  ..args
) = {
  import "imports.typ": fletcher.edge

  if type(a) == str { a = label(a) }
  if type(b) == str { b = label(b) }

  let opts = (dash: none, marks: ())

  if kind.type in ("realization", "dependency") {
    opts.dash = "densely-dashed"
  }
  let marks = if kind.type in ("realization", "generalization") {
    if kind.direction == "a-to-b" {
      opts.marks.push(none)
    }
    opts.marks.push("plum-|>")
  } else if kind.type in ("dependency",) {
    if kind.direction == "a-to-b" {
      opts.marks.push(none)
    }
    opts.marks.push("plum->")
  } else if kind.type in ("association",) {
    let (a, b) = kind
    let marks(end, side) = {
      let nav = end.at("navigable", default: none)
      let agg = end.at("aggregation", default: none)

      // the mark at the end indicating aggregation or navigability
      let mark = if nav == true {
        "plum->"
      } else if agg == "aggregate" {
        "plum-o"
      } else if agg == "composite" {
        "plum-*"
      }
      // the non-navigability is a bit inside the line, further for aggregations
      let x-mark = if nav == false {
        let x-mark = (inherit: "plum-x")
        x-mark.extrude = (if mark != none { 27 } else { 10 },)
        x-mark += if side == "a" { (pos: 0) } else { (pos: 1, rev: true) }
        (x-mark,)
      }
      (..x-mark, mark)
    }

    opts.marks += marks(a, "a").rev()
    opts.marks += marks(b, "b")
  }

  if bend != none {
    opts.bend = bend * 1rad
  }

  edge(a, ..via, b, ..opts, ..args)
  if kind.type in ("association",) {
    let fake-edge(pos, side, label) = {
      edge(
        a, ..via, b,
        ..opts,
        stroke: black.transparentize(100%),
        marks: (),
        label: label,
        label-pos: pos,
        label-side: side,
        ..args
      )
    }

    let fake-edges(pos, visibility: none, static: false, name: none, type: none, multiplicity: none) = {
      assert(not static, message: "static edges are not allowed")
      fake-edge(pos, left, {
        set text(0.8em)
        if visibility != none [#visibility ]
        name
        if type != none [: #type]
      })
      if multiplicity != none {
        fake-edge(pos, right, {
          set text(0.8em)
          multiplicity
        })
      }
    }

    let (a, b) = kind
    if "role" in a {
      fake-edges(0.15, ..a.role)
    }
    if "role" in b {
      fake-edges(0.85, ..b.role)
    }
  }
}

  // uml-edge(<subj>, <conc-subj>, "generalize-")
  // uml-edge(<obs>, <conc-obs>, "realize--")
  // uml-edge(
  //   <subj>, <obs>,
  //   marks: (
  //     "aggregate",
  //     (inherit: "non-navigable", pos: 0, rev: true, extrude: (-27,)),
  //     "navigable",
  //   ),
  //   labels: (
  //     // arguments([1], label-pos: 0.05, label-anchor: "south-west"),
  //     arguments([0..\*], label-pos: 0.95, label-anchor: "north-east", label-side: right),
  //     arguments([-- observers], label-pos: 0.95, label-anchor: "south-east", label-side: left),
  //   ),
  // )
  // uml-edge(
  //   <conc-obs>, <conc-subj>,
  //   marks: (
  //     "aggregate",
  //     (inherit: "non-navigable", pos: 0, rev: true, extrude: (-27,)),
  //     "navigable",
  //   ),
  //   labels: (
  //     // arguments([1], label-pos: 0.05, label-anchor: "south-east"),
  //     arguments([1], label-pos: 0.95, label-anchor: "south-west"),
  //     arguments([-- subject], label-pos: 0.95, label-anchor: "north-west", label-side: left),
  //   ),
  // )

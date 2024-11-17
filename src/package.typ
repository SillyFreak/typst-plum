#let package(
  name,
  pos: auto,
  members: none,
  ..args
) = {
  import "imports.typ": fletcher.node

  if members != none {
    let inset = 0.5em
    node(enclose: members, inset: inset, {
      block(outset: inset, inset: -inset, stroke: 0.5pt, width: 100%, height: 100%, {
        show: place.with(top+left)
        show: place.with(bottom+left)
        show: block.with(stroke: 0.5pt, inset: 0.3em)
        stack(dir: ttb, h(3em), name)
      })
    })
  } else {
    assert.ne(pos, auto, message: "automatic positioning is currently not supported. add #[pos(x, y)] to each package")

    let inset = 0.8em
    node(pos, {
      {
        show: place.with(top+left)
        show: place.with(bottom+left)
        block(stroke: 0.5pt, inset: 0.3em, width: 1.3em, height: 0.8em)
      }
      block(inset: inset, stroke: 0.5pt, name)
    })
  }
}

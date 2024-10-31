#import "template.typ" as template: *
#import "/src/lib.typ" as plum

#let package-meta = toml("/typst.toml").package
#let date = none
// #let date = datetime(year: ..., month: ..., day: ...)

#show: manual(
  title: "Plum",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML.
  ],
  url: package-meta.repository,
  version: package-meta.version,
  date: date,
)

// the scope for evaluating expressions and documentation
#let scope = (plum: plum)

= Introduction

This is a template for typst packages. It provides the #ref-fn("id()") function:

#file-code("lib.typ", {
  let lib = raw(block: true, lang: "typ", read("/src/lib.typ").trim(at: end))
  lib = crudo.lines(lib, "10-")
  lib
})

Here is the function in action:
#man-style.show-example(mode: "markup", dir: ttb, scope: scope, ```typ
one equals #plum.id[one], 1 = #plum.id(1)
```)

= Module reference

#module(
  read("/src/lib.typ"),
  name: "plum",
  label-prefix: none,
  scope: scope,
)

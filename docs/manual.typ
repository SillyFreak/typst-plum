#import "template.typ" as template: *
#import "/src/lib.typ" as plum

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: "Plum",
  subtitle: [
    _Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML.
  ],
  date: none,
  // date: datetime(year: ..., month: ..., day: ...),

  // logo: rect(width: 5cm, height: 5cm),
  // abstract: [
  //   A PACKAGE for something
  // ],

  scope: (plum: plum),
)

= Introduction

 _Plum_ lets you create UML class diagrams in Typst; inspired by but _not_ compatible with PlantUML. It provides the #ref-fn("parse()") and #ref-fn("plum()") functions.

= Module reference

#module(
  read("/src/lib.typ"),
  name: "plum",
  label-prefix: none,
)

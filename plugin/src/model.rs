use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(bound(deserialize = "'de: 'input"))]
pub struct Diagram<'input> {
    pub classifiers: Vec<Classifier<'input>>,
    // pub links: Vec<Link<'input>>,
}

/// A [classifier](https://www.uml-diagrams.org/classifier.html).
/// See [ClassKind] for the supported kinds of classifiers.
#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Classifier<'input> {
    pub is_abstract: bool,
    pub is_final: bool,
    pub kind: ClassifierKind,
    pub name: &'input str,
    pub stereotypes: Vec<&'input str>,
}

/// Supported kinds of classifiers. An overview can be found in the UL 2.5 spec,
/// table C.1 (keywords). There's no keyword for "class", not all keywords are classifier kinds,
/// and not all classifier kinds are relevant to class diagrams.
/// As a result the selection here is somewhat opinionated.
#[derive(Serialize, Deserialize, Debug, Clone, Copy, PartialEq)]
#[serde(rename_all = "kebab-case", rename_all_fields = "kebab-case")]
pub enum ClassifierKind {
    Class,
    DataType,
    Enumeration,
    Interface,
    Primitive,
    Annotation,
}

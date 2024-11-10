use std::collections::BTreeMap;
use std::fmt;

use serde::{Deserialize, Serialize};

use super::{helpers, Meta};

mod attribute;

pub use attribute::Attribute;

/// A [classifier](https://www.uml-diagrams.org/classifier.html).
/// See [ClassKind] for the supported kinds of classifiers.
#[derive(Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Classifier<'input> {
    #[serde(flatten)]
    pub meta: BTreeMap<&'input str, Meta>,
    #[serde(rename = "abstract", skip_serializing_if = "helpers::is_false")]
    pub is_abstract: bool,
    #[serde(rename = "final", skip_serializing_if = "helpers::is_false")]
    pub is_final: bool,
    pub kind: ClassifierKind,
    pub name: &'input str,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub stereotypes: Vec<&'input str>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub attributes: Vec<Attribute<'input>>,
}

impl fmt::Debug for Classifier<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if !self.meta.is_empty() {
            let mut iter = self.meta.values();
            write!(f, "#[{:?}", iter.next().unwrap())?;
            for meta in iter {
                write!(f, ", {:?}", meta)?;
            }
            write!(f, "]\n")?;
        }

        if self.is_abstract && self.kind != ClassifierKind::Interface {
            write!(f, "abstract ")?;
        }
        if self.is_final {
            write!(f, "final ")?;
        }
        // let keyword = Some(self.kind).filter(|kind| *kind != ClassifierKind::Class);
        // let mut keyword_and_stereotypes = keyword
        //     .into_iter()
        //     .map(|kind| kind.kind())
        //     .chain(self.stereotypes.iter().copied());
        // if let Some(x) = keyword_and_stereotypes.next() {
        //     write!(f, "«{}", x)?;
        //     for x in keyword_and_stereotypes {
        //         write!(f, ", {}", x)?;
        //     }
        //     write!(f, "» ")?;
        // }
        let mut stereotypes = self.stereotypes.iter().copied();
        if let Some(x) = stereotypes.next() {
            write!(f, "«{}", x)?;
            for x in stereotypes {
                write!(f, ", {}", x)?;
            }
            write!(f, "» ")?;
        }
        write!(f, "{} {}", self.kind, self.name)?;

        if !self.attributes.is_empty() {
            write!(f, " {{")?;
            for attr in &self.attributes {
                write!(f, "\n  {:?}", attr)?;
            }
            write!(f, "\n}}")?;
        }

        Ok(())
    }
}

/// Supported kinds of classifiers. An overview can be found in the UL 2.5 spec,
/// table C.1 (keywords). There's no keyword for "class", not all keywords are classifier kinds,
/// and not all classifier kinds are relevant to class diagrams.
/// As a result the selection here is somewhat opinionated.
#[derive(Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "kebab-case", rename_all_fields = "kebab-case")]
pub enum ClassifierKind {
    Class,
    DataType,
    Enumeration,
    Interface,
    Primitive,
}

impl ClassifierKind {
    pub fn kind(self) -> &'static str {
        match self {
            Self::Class => "class",
            Self::DataType => "dataType",
            Self::Enumeration => "enumeration",
            Self::Interface => "interface",
            Self::Primitive => "primitive",
        }
    }
}

impl fmt::Debug for ClassifierKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.kind())
    }
}

impl fmt::Display for ClassifierKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.kind())
    }
}

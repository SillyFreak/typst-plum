use std::collections::BTreeMap;
use std::fmt;

use serde::{Deserialize, Serialize};

use super::{Attribute, Meta};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(bound(deserialize = "'de: 'input"), rename_all = "kebab-case")]
pub struct Edge<'input> {
    #[serde(flatten)]
    pub meta: BTreeMap<&'input str, Meta>,
    pub a: &'input str,
    pub b: &'input str,
    pub kind: EdgeKind<'input>,
}

impl fmt::Display for Edge<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let mut meta = self.meta.values();
        if let Some(x) = meta.next() {
            write!(f, "#[{}", x)?;
            for x in meta {
                write!(f, ", {}", x)?;
            }
            write!(f, "]\n")?;
        }

        write!(f, "{} {} {}", self.a, self.kind, self.b)
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(
    bound(deserialize = "'de: 'input"),
    tag = "type",
    rename_all = "kebab-case",
    rename_all_fields = "kebab-case"
)]
pub enum EdgeKind<'input> {
    Realization {
        direction: Direction,
    },
    Generalization {
        direction: Direction,
    },
    Dependency {
        direction: Option<Direction>,
        #[serde(skip_serializing_if = "Option::is_none")]
        name: Option<&'input str>,
    },
    Association {
        #[serde(skip_serializing_if = "Option::is_none")]
        name: Option<&'input str>,
        a: AssociationEnd<'input>,
        b: AssociationEnd<'input>,
    },
}

impl fmt::Display for EdgeKind<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Direction as D;

        match self {
            Self::Realization { direction: D::AToB } => write!(f, "..|>"),
            Self::Realization { direction: D::BToA } => write!(f, "<|.."),
            Self::Generalization { direction: D::AToB } => write!(f, "--|>"),
            Self::Generalization { direction: D::BToA } => write!(f, "<|--"),
            Self::Dependency {
                direction: None,
                name,
            } => write!(f, ".{}.", name.unwrap_or_default()),
            Self::Dependency {
                direction: Some(D::AToB),
                name,
            } => write!(f, ".{}.>", name.unwrap_or_default()),
            Self::Dependency {
                direction: Some(D::BToA),
                name,
            } => write!(f, "<.{}.", name.unwrap_or_default()),
            Self::Association { name, a, b } => {
                write!(f, "{:#}-{}-{}", a, name.unwrap_or_default(), b)
            }
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub enum Direction {
    AToB,
    BToA,
}

#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(bound(deserialize = "'de: 'input"), rename_all = "kebab-case")]
pub struct AssociationEnd<'input> {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub aggregation: Option<Aggregation>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub navigable: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub role: Option<Attribute<'input>>,
}

impl fmt::Display for AssociationEnd<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Aggregation as A;

        if f.alternate() {
            if let Some(role) = &self.role {
                write!(f, "({}) ", role)?;
            }
        }
        match (self.aggregation, self.navigable, f.alternate()) {
            (Some(A::Aggregate), Some(false), false) => write!(f, "x-o")?,
            (Some(A::Aggregate), Some(false), true) => write!(f, "o-x")?,
            (Some(A::Aggregate), _, _) => write!(f, "o")?,
            (Some(A::Composite), Some(false), false) => write!(f, "x-*")?,
            (Some(A::Composite), Some(false), true) => write!(f, "*-x")?,
            (Some(A::Composite), _, _) => write!(f, "*")?,
            (None, None, _) => write!(f, "")?,
            (None, Some(false), _) => write!(f, "x")?,
            (None, Some(true), false) => write!(f, ">")?,
            (None, Some(true), true) => write!(f, "<")?,
        }
        if !f.alternate() {
            if let Some(role) = &self.role {
                write!(f, " ({})", role)?;
            }
        }

        Ok(())
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Copy, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub enum Aggregation {
    Aggregate,
    Composite,
}

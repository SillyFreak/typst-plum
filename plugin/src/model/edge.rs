use std::fmt;

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(
    bound(deserialize = "'de: 'input"),
    tag = "type",
    rename_all = "kebab-case"
)]
pub struct Edge<'input> {
    pub a: &'input str,
    pub b: &'input str,
    pub kind: EdgeKind<'input>,
}

impl fmt::Display for Edge<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
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
        direction: Direction,
        name: Option<&'input str>,
    },
    Association {
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
                direction: D::AToB,
                name,
            } => write!(f, ".{}.>", name.unwrap_or_default()),
            Self::Dependency {
                direction: D::BToA,
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
#[serde(rename_all = "kebab-case")]
pub struct AssociationEnd<'input> {
    pub aggregation: Option<Aggregation>,
    pub navigable: Option<bool>,
    pub role: Option<&'input str>,
    pub multiplicity: Option<&'input str>,
}

impl fmt::Display for AssociationEnd<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Aggregation as A;

        match (self.aggregation, self.navigable, f.alternate()) {
            (Some(A::Aggregate), Some(false), false) => write!(f, "x-o"),
            (Some(A::Aggregate), Some(false), true) => write!(f, "o-x"),
            (Some(A::Aggregate), _, _) => write!(f, "o"),
            (Some(A::Composite), Some(false), false) => write!(f, "x-*"),
            (Some(A::Composite), Some(false), true) => write!(f, "*-x"),
            (Some(A::Composite), _, _) => write!(f, "*"),
            (None, None, _) => write!(f, ""),
            (None, Some(false), _) => write!(f, "x"),
            (None, Some(true), false) => write!(f, ">"),
            (None, Some(true), true) => write!(f, "<"),
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Copy, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub enum Aggregation {
    Aggregate,
    Composite,
}

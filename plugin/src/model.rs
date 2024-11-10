use std::fmt;

use either::Either;
use serde::{Deserialize, Serialize};

mod helpers;

mod classifier;
mod edge;

pub use classifier::*;
pub use edge::*;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(bound(deserialize = "'de: 'input"))]
pub struct Diagram<'input> {
    pub classifiers: Vec<Classifier<'input>>,
    pub edges: Vec<Edge<'input>>,
}

impl fmt::Display for Diagram<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let classifiers = self.classifiers.iter().map(Either::Left);
        let edges = self.edges.iter().map(Either::Right);
        let mut items = classifiers.chain(edges);
        if let Some(x) = items.next() {
            write!(f, "{}", x)?;
            for x in items {
                write!(f, "\n{}", x)?;
            }
        }
        Ok(())
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
// #[serde(bound(deserialize = "'de: 'input"))]
#[serde(untagged)]
pub enum Meta {
    Position(isize, isize),
}

impl Meta {
    pub fn name(&self) -> &'static str {
        match self {
            Self::Position(_, _) => "pos",
        }
    }
}

impl fmt::Display for Meta {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::Position(x, y) => write!(f, "pos({x}, {y})"),
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Copy, PartialEq)]
pub enum Visibility {
    #[serde(rename = "-")]
    Private,
    #[serde(rename = "~")]
    Package,
    #[serde(rename = "#")]
    Protected,
    #[serde(rename = "+")]
    Public,
}

impl fmt::Display for Visibility {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::Private => write!(f, "-"),
            Self::Package => write!(f, "~"),
            Self::Protected => write!(f, "#"),
            Self::Public => write!(f, "+"),
        }
    }
}

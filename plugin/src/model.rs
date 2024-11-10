use std::fmt;

use serde::{Deserialize, Serialize};

mod helpers;

mod classifier;

pub use classifier::*;

#[derive(Serialize, Deserialize, Clone, PartialEq)]
#[serde(bound(deserialize = "'de: 'input"))]
pub struct Diagram<'input> {
    pub classifiers: Vec<Classifier<'input>>,
    // pub links: Vec<Link<'input>>,
}

impl fmt::Debug for Diagram<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let mut classifiers = self.classifiers.iter();
        if let Some(x) = classifiers.next() {
            write!(f, "{:?}", x)?;
            for x in classifiers {
                write!(f, "\n{:?}", x)?;
            }
        }
        Ok(())
    }
}

#[derive(Serialize, Deserialize, Clone, PartialEq)]
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

impl fmt::Debug for Meta {
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

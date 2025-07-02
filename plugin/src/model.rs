use std::f32::consts::PI;
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
    Position(f32, f32),
    Via(Vec<(f32, f32)>),
    Bend(f32),
}

impl Meta {
    pub fn name(&self) -> &'static str {
        match self {
            Self::Position(_, _) => "position",
            Self::Via(_) => "via",
            Self::Bend(_) => "bend",
        }
    }
}

impl fmt::Display for Meta {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}(", self.name())?;
        match self {
            Self::Position(x, y) => write!(f, "{x}, {y}")?,
            Self::Via(points) => {
                let mut points = points.iter();
                if let Some((x, y)) = points.next() {
                    write!(f, "({x}, {y})")?;
                    for (x, y) in points {
                        write!(f, ", ({x}, {y})")?;
                    }
                }
            }
            Self::Bend(angle) => {
                write!(f, "{}deg", angle * 180.0 / PI)?;
            }
        }
        write!(f, ")")?;
        Ok(())
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

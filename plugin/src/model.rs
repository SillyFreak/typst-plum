use serde::{Serialize, Deserialize};

mod classifier;

pub use classifier::*;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(bound(deserialize = "'de: 'input"))]
pub struct Diagram<'input> {
    pub classifiers: Vec<Classifier<'input>>,
    // pub links: Vec<Link<'input>>,
}

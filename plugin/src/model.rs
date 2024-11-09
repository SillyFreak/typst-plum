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

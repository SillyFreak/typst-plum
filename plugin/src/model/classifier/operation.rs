use std::borrow::Cow;
use std::fmt;

use serde::{Deserialize, Serialize};

use crate::model::Visibility;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Operation<'input> {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub visibility: Option<Visibility>,
    pub name: &'input str,
    pub parameters: Vec<Parameter<'input>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub return_type: Option<Cow<'input, str>>,
}

impl fmt::Display for Operation<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(visibility) = self.visibility {
            write!(f, "{} ", visibility)?;
        }
        write!(f, "{}(", self.name)?;
        let mut parameters = self.parameters.iter();
        if let Some(x) = parameters.next() {
            write!(f, "{}", x)?;
            for x in parameters {
                write!(f, ", {}", x)?;
            }
        }
        write!(f, ")")?;
        if let Some(return_type) = &self.return_type {
            write!(f, ": {}", return_type)?;
        }
        Ok(())
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Parameter<'input> {
    pub name: &'input str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Cow<'input, str>>,
}

impl fmt::Display for Parameter<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.name)?;
        if let Some(r#type) = &self.r#type {
            write!(f, ": {}", r#type)?;
        }
        Ok(())
    }
}

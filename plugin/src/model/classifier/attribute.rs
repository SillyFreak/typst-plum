use std::fmt;

use serde::{Deserialize, Serialize};

use crate::model::Visibility;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Attribute<'input> {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub visibility: Option<Visibility>,
    pub name: &'input str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<&'input str>,
}

impl fmt::Display for Attribute<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(visibility) = self.visibility {
            write!(f, "{} ", visibility)?;
        }
        write!(f, "{}", self.name)?;
        if let Some(r#type) = self.r#type {
            write!(f, ": {}", r#type)?;
        }
        Ok(())
    }
}

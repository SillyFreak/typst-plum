use serde::{Deserialize, Serialize};

use crate::model::Visibility;

#[derive(Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Attribute<'input> {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub visibility: Option<Visibility>,
    pub name: &'input str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<&'input str>,
}

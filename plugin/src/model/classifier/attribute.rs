use std::borrow::Cow;
use std::fmt;
use std::num::ParseIntError;
use std::str::FromStr;

use serde::{Deserialize, Serialize};

use crate::model::Visibility;
use super::helpers;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub struct Attribute<'input> {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub visibility: Option<Visibility>,
    #[serde(skip_serializing_if  = "helpers::is_false")]
    pub r#static: bool,
    pub name: &'input str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub r#type: Option<Cow<'input, str>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub multiplicity: Option<MultiplicityRange>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub modifiers: Vec<Modifier<'input>>,
}

impl fmt::Display for Attribute<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(visibility) = self.visibility {
            write!(f, "{} ", visibility)?;
        }
        if self.r#static {
            write!(f, "static ")?;
        }
        write!(f, "{}", self.name)?;
        if let Some(r#type) = &self.r#type {
            write!(f, ": {}", r#type)?;
        }
        if let Some(multiplicity) = &self.multiplicity {
            write!(f, " [{}]", multiplicity)?;
        }
        let mut modifiers = self.modifiers.iter();
        if let Some(x) = modifiers.next() {
            write!(f, " {{{}", x)?;
            for x in modifiers {
                write!(f, ", {}", x)?;
            }
            write!(f, "}}")?;
        }
        Ok(())
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum MultiplicityRange {
    Exact(Multiplicity),
    Range(Multiplicity, Multiplicity),
}

impl fmt::Display for MultiplicityRange {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            MultiplicityRange::Exact(number) => write!(f, "{}", number)?,
            MultiplicityRange::Range(lower, upper) => write!(f, "{}..{}", lower, upper)?,
        }
        Ok(())
    }
}

impl serde::Serialize for MultiplicityRange {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(&format!("{}", self))
    }
}

impl<'de> serde::Deserialize<'de> for MultiplicityRange {
    fn deserialize<D>(deserializer: D) -> Result<MultiplicityRange, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        use serde::de::{self, Visitor};

        struct MultiplicityRangeVisitor;

        impl<'de> Visitor<'de> for MultiplicityRangeVisitor {
            type Value = MultiplicityRange;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter
                    .write_str("a multiplicity (e.g. 0, *) or multiplicity range (e.g. 0..2, 1..*)")
            }

            fn visit_str<E>(self, value: &str) -> Result<Self::Value, E>
            where
                E: de::Error,
            {
                let mut parts = value.split("..");
                let first = parts
                    .next()
                    .expect("splitting should result in at least one part");
                let second = parts.next();
                if !parts.next().is_none() {
                    return Err(de::Error::invalid_value(de::Unexpected::Str(value), &self));
                }
                let first = Multiplicity::from_str(first)
                    .map_err(|_| de::Error::invalid_value(de::Unexpected::Str(value), &self))?;
                let second = second
                    .map(|second| {
                        Multiplicity::from_str(second).map_err(|_| {
                            de::Error::invalid_value(de::Unexpected::Str(value), &self)
                        })
                    })
                    .transpose()?;
                let result = match (first, second) {
                    (number, None) => MultiplicityRange::Exact(number),
                    (lower, Some(upper)) => MultiplicityRange::Range(lower, upper),
                };
                Ok(result)
            }
        }

        deserializer.deserialize_str(MultiplicityRangeVisitor)
    }
}
#[derive(Debug, Clone, PartialEq)]
pub enum Multiplicity {
    Any,
    Number(isize),
}

impl fmt::Display for Multiplicity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Multiplicity as M;
        match self {
            M::Any => write!(f, "*"),
            M::Number(number) => write!(f, "{}", number),
        }
    }
}

impl FromStr for Multiplicity {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim() {
            "*" => Ok(Multiplicity::Any),
            _ => Ok(Multiplicity::Number(s.parse()?)),
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum Modifier<'input> {
    Id,
    ReadOnly,
    Ordered,
    Unique,
    Nonunique,
    Sequence,
    Union,
    Redefines(&'input str),
    Subsets(&'input str),
    Constraint(Cow<'input, str>),
}

impl fmt::Display for Modifier<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Modifier as M;
        match self {
            M::Id => write!(f, "id"),
            M::ReadOnly => write!(f, "readOnly"),
            M::Ordered => write!(f, "ordered"),
            M::Unique => write!(f, "unique"),
            M::Nonunique => write!(f, "nonunique"),
            M::Sequence => write!(f, "seq"),
            M::Union => write!(f, "union"),
            M::Redefines(s) => write!(f, "redefines {}", s),
            M::Subsets(s) => write!(f, "subsets {}", s),
            M::Constraint(s) => write!(f, "{}", s),
        }
    }
}

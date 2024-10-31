// taken from https://github.com/lalrpop/lalrpop/blob/793df8d6b4fa1c1bc9c253ee7c173d25cb202a9d/doc/calculator/src/ast.rs
// Copyright (c) 2015 The LALRPOP Project Developers
// used under the MIT license:
// https://github.com/lalrpop/lalrpop/blob/793df8d6b4fa1c1bc9c253ee7c173d25cb202a9d/LICENSE-MIT

use std::fmt::{Debug, Error, Formatter};
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Clone, PartialEq)]
#[serde(tag = "type")]
#[serde(rename_all = "kebab-case", rename_all_fields = "kebab-case")]
pub enum Expr<'input> {
    Number {
        value: i32,
    },
    Variable {
        name: &'input str,
    },
    Binary {
        operator: Operator,
        left: Box<Expr<'input>>,
        right: Box<Expr<'input>>,
    },
}

#[derive(Serialize, Deserialize, Clone, Copy, PartialEq)]
#[serde(rename_all = "kebab-case", rename_all_fields = "kebab-case")]
pub enum Operator {
    Mul,
    Div,
    Add,
    Sub,
}

impl<'input> Debug for Expr<'input> {
    fn fmt(&self, fmt: &mut Formatter) -> Result<(), Error> {
        use self::Expr::*;
        match *self {
            Number { value } => write!(fmt, "{:?}", value),
            Variable { name } => write!(fmt, "{}", name),
            Binary {
                operator,
                ref left,
                ref right,
             } => write!(fmt, "({:?} {:?} {:?})", left, operator, right),
        }
    }
}

impl Debug for Operator {
    fn fmt(&self, fmt: &mut Formatter) -> Result<(), Error> {
        use self::Operator::*;
        match *self {
            Mul => write!(fmt, "*"),
            Div => write!(fmt, "/"),
            Add => write!(fmt, "+"),
            Sub => write!(fmt, "-"),
        }
    }
}
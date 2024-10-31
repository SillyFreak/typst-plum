use lalrpop_util::lexer::Token;
use lalrpop_util::ParseError;

use crate::ast;

lalrpop_util::lalrpop_mod!(
    #[allow(clippy::all)] grammar,
    "/parser/grammar.rs"
);

pub type Error<'a> = ParseError<usize, Token<'a>, &'static str>;
pub type Result<'a, T> = std::result::Result<T, Error<'a>>;

pub fn parse(source: &str) -> Result<ast::Expr<'_>> {
    let parser = grammar::ExprParser::new();
    parser.parse(source)
}

#[cfg(test)]
mod tests {
    use super::*;

    pub fn test_parse(input: &str, expected: &str) {
        let actual = parse(input).unwrap();
        assert_eq!(format!("{actual:?}"), expected);
    }

    #[test]
    fn test_parse_number() {
        test_parse(" 0", "0");
        test_parse(" 2 ", "2");
        test_parse("11 ", "11");
        test_parse("(12 )", "12");
    }

    #[test]
    fn test_parse_variable() {
        test_parse(" x", "x");
        test_parse("_y", "_y");
        test_parse("foo ", "foo");
        test_parse(" a-b ", "a-b");
    }

    #[test]
    fn test_parse_binary() {
        test_parse("( 0 + 2)", "(0 + 2)");
        test_parse(" (2 ) - x", "(2 - x)");
        test_parse("(11 / (2))", "(11 / 2)");
        test_parse("x*y", "(x * y)");
    }

    #[test]
    fn test_parse_nested() {
        test_parse("1+1*3", "(1 + (1 * 3))");
        test_parse("(2+1)* x", "((2 + 1) * x)");
    }
}

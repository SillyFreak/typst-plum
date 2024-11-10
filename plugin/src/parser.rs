use lalrpop_util::lexer::Token;
use lalrpop_util::ParseError;

use crate::model;

lalrpop_util::lalrpop_mod!(
    #[allow(clippy::all)]
    grammar,
    "/grammar.rs"
);

pub type Error<'a> = ParseError<usize, Token<'a>, &'static str>;
pub type Result<'a, T> = std::result::Result<T, Error<'a>>;

pub fn parse(source: &str) -> Result<model::Diagram<'_>> {
    let parser = grammar::DiagramParser::new();
    parser.parse(source)
}

#[cfg(test)]
mod tests {
    use super::*;

    pub fn test_parse(input: &str, expected: &str) {
        let actual = parse(input).unwrap();
        assert_eq!(format!("{:?}", actual), expected);
    }

    #[test]
    fn test_parse_diagram() {
        test_parse("class A", "class A");
        test_parse("abstract class A", "abstract class A");
        test_parse("interface A", "interface A");
        test_parse("final class A", "final class A");
        test_parse("exception A", "«exception» class A");
        test_parse("annotation A", "«annotation» interface A");

        test_parse("class A\n\nclass B", "class A\nclass B");
    }

    #[test]
    fn test_parse_class_body() {
        test_parse("class A", "class A");
        test_parse("class A{}", "class A");
        test_parse("class A {}", "class A");
        test_parse("class A { }", "class A");
        test_parse("class A {\n}", "class A");
        test_parse("class A {\n\n}", "class A");
        test_parse(r#"
            class A {
                - attr
            }"#, "class A {\n  - attr\n}");
        test_parse(r#"
            class A {
                - attr
                + attr2
            }"#, "class A {\n  - attr\n  + attr2\n}");
    }
}

use std::borrow::Cow;

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

fn from_mark(mark: &str) -> model::AssociationEnd {
    let mut end = model::AssociationEnd::default();
    if mark.contains("<") || mark.contains(">") {
        end.navigable = Some(true);
    } else {
        if mark.contains("x") {
            end.navigable = Some(false);
        }
        if mark.contains("o") {
            end.aggregation = Some(model::Aggregation::Aggregate);
        } else if mark.contains("*") {
            end.aggregation = Some(model::Aggregation::Composite);
        }
    }
    end
}

fn parse_string(string: &str) -> Cow<'_, str> {
    // TODO process escape sequences
    Cow::from(&string[1..string.len() - 1])
}

#[cfg(test)]
mod tests {
    use super::*;

    pub fn test_parse(input: &str, expected: &str) {
        let actual = parse(input).unwrap();
        assert_eq!(format!("{}", actual), expected);
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

        test_parse("#[pos(0, 0)] class A", "#[pos(0, 0)]\nclass A");
        test_parse("#[pos(0, 0)]\nclass A", "#[pos(0, 0)]\nclass A");
        test_parse("#[pos(0, 0)]\n\nclass A", "#[pos(0, 0)]\nclass A");
    }

    #[test]
    fn test_parse_class_body() {
        test_parse("class A", "class A");
        test_parse("class A{}", "class A");
        test_parse("class A {}", "class A");
        test_parse("class A { }", "class A");
        test_parse("class A {\n}", "class A");
        test_parse("class A {\n\n}", "class A");
        test_parse(
            r#"
            class  A  {
                 - attr:  Foo
                + op ( ) :  Bar
            }"#,
            "class A {\n  - attr: Foo\n  + op(): Bar\n}",
        );
        test_parse(
            r#"
            class A {
                - attr
                +   attr2: "Baz<T>"
                + op( x, )
                + op(x:  X , y: Y): Z
            }"#,
            "class A {\n  - attr\n  + attr2: Baz<T>\n  + op(x)\n  + op(x: X, y: Y): Z\n}",
        );
    }

    #[test]
    fn test_parse_edges() {
        test_parse("A  -- B", "A -- B");
        test_parse("A  --> B", "A --> B");
        test_parse("A  <-- B", "A <-- B");
        test_parse("A  o--x B", "A o--x B");
        test_parse("A  *-x--> B", "A *-x--> B");
        test_parse("A  --|> B", "A --|> B");
        test_parse("A  <|.. B", "A <|.. B");
        test_parse("A  <.. B", "A <.. B");

        test_parse("#[via((0, 0))] A  -- B", "#[via((0, 0))]\nA -- B");
        test_parse("#[via((0, 0), (1, 0))] A  -- B", "#[via((0, 0), (1, 0))]\nA -- B");
    }
}

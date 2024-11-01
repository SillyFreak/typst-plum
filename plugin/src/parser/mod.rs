use lalrpop_util::lexer::Token;
use lalrpop_util::ParseError;

use crate::model;

lalrpop_util::lalrpop_mod!(
    #[allow(clippy::all)] grammar,
    "/parser/grammar.rs"
);

pub type Error<'a> = ParseError<usize, Token<'a>, &'static str>;
pub type Result<'a, T> = std::result::Result<T, Error<'a>>;

pub fn parse(source: &str) -> Result<model::Diagram<'_>> {
    let parser = grammar::DiagramParser::new();
    parser.parse(source)
}

#[cfg(test)]
mod tests {
    use crate::model::*;

    use super::*;

    pub fn test_parse(input: &str, expected: &Diagram<'_>) {
        let actual = parse(input).unwrap();
        assert_eq!(&actual, expected);
    }

    #[test]
    fn test_parse_diagram() {
        fn single_class(classifier: Classifier<'_>) -> Diagram<'_> {
            Diagram {
                classifiers: vec![classifier]
            }
        }
        test_parse("class A", &single_class(
            Classifier {
                is_abstract: false,
                is_final: false,
                kind: ClassifierKind::Class,
                name: "A",
                stereotypes: vec![],
            }
        ));
        test_parse("abstract class A", &single_class(
            Classifier {
                is_abstract: true,
                is_final: false,
                kind: ClassifierKind::Class,
                name: "A",
                stereotypes: vec![],
            }
        ));
        test_parse("interface A", &single_class(
            Classifier {
                is_abstract: true,
                is_final: false,
                kind: ClassifierKind::Interface,
                name: "A",
                stereotypes: vec![],
            }
        ));
        test_parse("final class A", &single_class(
            Classifier {
                is_abstract: false,
                is_final: true,
                kind: ClassifierKind::Class,
                name: "A",
                stereotypes: vec![],
            }
        ));
        test_parse("exception A", &single_class(
            Classifier {
                is_abstract: false,
                is_final: false,
                kind: ClassifierKind::Class,
                name: "A",
                stereotypes: vec!["exception"],
            }
        ));
    }
}

#let _p = plugin("parser.wasm")

/// Parses an expression via a WASM plugin.
///
/// #example(mode: "markup", ```typ
/// #plum.parse("1") \
/// #plum.parse("1 + 1") \
/// #plum.parse("foo") \
/// #plum.parse("foo + 1")
/// ```)
///
/// - expr (str): the expression to parse
/// -> dict
#let parse(expr) = {
  // this is the "interesting" part: calling into the Rust parser
  cbor.decode(_p.parse(cbor.encode(expr)))
}

/// Evaluates an expression in Typst, by traversing the abstract syntax tree (AST) created in Rust.
///
/// #example(mode: "markup", ```typ
/// #plum.eval("1") \
/// #plum.eval("1 + 1") \
/// #plum.eval("foo", foo: 1) \
/// #plum.eval("foo + 1", foo: 1)
/// ```)
///
/// - expr (str): the expression to evaluate
/// - ..vars (arguments): the variable assignments in the expression
/// -> int
#let eval(expr, ..vars) = {
  assert(vars.pos().len() == 0)
  let vars = vars.named()

  let inner-eval(expr) = {
    if expr.type == "number" { expr.value }
    else if expr.type == "variable" { vars.at(expr.name) }
    else if expr.type == "binary" {
      let (operator, left, right) = expr
      (left, right) = (inner-eval(left), inner-eval(right))
      if operator == "add" { left + right }
      else if operator == "sub" { left - right }
      else if operator == "mul" { left * right }
      else if operator == "div" { left / right }
      else { panic("unexpected binary operator: " + operator) }
    }
    else { panic("unexpected expression type: " + expr.type) }
  }

  inner-eval(parse(expr))
}

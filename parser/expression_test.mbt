///|
fn scan(src : String) -> (String, String) raise @parser.ParseError {
  let (expr, rest) = @parser.scan_expression(src[:], 0)
  (expr, rest.to_owned())
}

///|
test "plain expression" {
  assert_eq(scan("name}"), ("name", ""))
  assert_eq(scan("name}tail"), ("name", "tail"))
}

///|
test "nested brackets do not close the expression" {
  assert_eq(scan("f(a)}"), ("f(a)", ""))
  assert_eq(scan("a[0]}"), ("a[0]", ""))
  assert_eq(scan("{ x: 1 }.x}"), ("{ x: 1 }.x", ""))
  assert_eq(scan("f({ x: 1 }, [2])}"), ("f({ x: 1 }, [2])", ""))
}

///|
test "brace inside a string literal is ignored" {
  assert_eq(scan("\"}\"}"), ("\"}\"", ""))
  assert_eq(scan("\"a}b\"}tail"), ("\"a}b\"", "tail"))
}

///|
test "escaped quote inside a string literal does not end it" {
  assert_eq(scan("\"a\\\"}b\"}"), ("\"a\\\"}b\"", ""))
}

///|
test "brace inside a rune literal is ignored" {
  assert_eq(scan("'}'}"), ("'}'", ""))
}

///|
test "brace inside comments is ignored" {
  assert_eq(scan("/* } */ x}"), ("/* } */ x", ""))
  assert_eq(scan("// }\nx}"), ("// }\nx", ""))
}

///|
test "expression with no closing brace is an error" {
  let err = try @parser.scan_expression("name"[:], 7) catch {
    e => e
  } noraise {
    _ => @parser.ParseError(offset=0, message="no error")
  }
  assert_eq(
    err,
    @parser.ParseError(offset=7, message="unterminated expression"),
  )
}

///|
test "unterminated string literal is an error" {
  let err = try @parser.scan_expression("\"abc"[:], 0) catch {
    e => e
  } noraise {
    _ => @parser.ParseError(offset=0, message="no error")
  }
  assert_eq(
    err,
    @parser.ParseError(offset=0, message="unterminated expression"),
  )
}

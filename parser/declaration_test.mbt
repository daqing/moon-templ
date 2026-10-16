///|
fn doc_type(value : String) -> @parser.Node {
  DocType(value)
}

///|
fn comment(contents : String) -> @parser.Node {
  HTMLComment(contents)
}

///|
test "a doctype carries the value between the keyword and the angle bracket" {
  assert_eq(parse("<!doctype html>"), [doc_type("html")])
  assert_eq(parse("<!doctype svg>"), [doc_type("svg")])
}

///|
test "the doctype keyword is matched without regard to case" {
  assert_eq(parse("<!DOCTYPE html>"), [doc_type("html")])
  assert_eq(parse("<!DoCtYpE html>"), [doc_type("html")])
}

///|
test "a doctype value with a space in it is kept whole" {
  assert_eq(parse("<!doctype html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">"), [
    doc_type("html PUBLIC \"-//W3C//DTD HTML 4.01//EN\""),
  ])
}

///|
/// The keyword and the value are separated by a space; without it this is not a
/// doctype, and the element parser reports the `!` it chokes on.
test "the doctype keyword needs its separating space" {
  assert_eq(
    error_of("<!doctypehtml>"),
    @parser.ParseError(
      offset=0,
      message="element name must start with a lowercase letter: !",
    ),
  )
}

///|
test "an unclosed doctype is an error" {
  assert_eq(
    error_of("<!doctype html"),
    @parser.ParseError(offset=0, message="unclosed DOCTYPE"),
  )
  assert_eq(
    error_of("<!doctype html<"),
    @parser.ParseError(offset=0, message="unclosed DOCTYPE"),
  )
  assert_eq(
    error_of("<!doctype "),
    @parser.ParseError(offset=0, message="unclosed DOCTYPE"),
  )
}

///|
test "an HTML comment carries its contents without the delimiters" {
  assert_eq(parse("<!--note-->"), [comment("note")])
  assert_eq(parse("<!---->"), [comment("")])
  assert_eq(parse("<!-- a b -->"), [comment(" a b ")])
}

///|
/// A comment is not template syntax: braces and angle brackets in it are text.
test "a comment is not scanned for expressions or tags" {
  assert_eq(parse("<!--{ name } <div>-->"), [comment("{ name } <div>")])
}

///|
test "an unterminated comment is an error" {
  assert_eq(
    error_of("<!--note"),
    @parser.ParseError(
      offset=0,
      message="expected end comment literal '-->' not found",
    ),
  )
}

///|
/// templ reads contents up to the first `--` and then insists on `>`, so a `--`
/// inside a comment is a mistake rather than part of the text.
test "a double hyphen inside a comment is an error" {
  assert_eq(
    error_of("<!--a--b-->"),
    @parser.ParseError(
      offset=0,
      message="comment contains invalid sequence '--'",
    ),
  )
  assert_eq(
    error_of("<!--a--"),
    @parser.ParseError(
      offset=0,
      message="comment contains invalid sequence '--'",
    ),
  )
}

///|
test "a doctype and a comment sit among the nodes around them" {
  assert_eq(parse("<!doctype html><div><!--x--></div>"), [
    doc_type("html"),
    el("div", [comment("x")], false),
  ])
}

///|
test "a comment between two text runs keeps them apart" {
  assert_eq(parse("a<!--x-->b"), [Text("a"), comment("x"), Text("b")])
}

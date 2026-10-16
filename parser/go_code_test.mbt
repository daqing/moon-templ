///|
/// The code inside `{{ ... }}` is kept as it stands apart from the whitespace that
/// pads it against the braces, which is syntax rather than part of the code.
test "a go code block holds the code between its braces" {
  assert_eq(parse("{{ let x = 1 }}"), [GoCode("let x = 1")])
  assert_eq(parse("{{let x = 1}}"), [GoCode("let x = 1")])
  assert_eq(parse("{{ f(a, b) }}"), [GoCode("f(a, b)")])
}

///|
/// A block is code, so it may hold several statements over several lines, and the
/// newlines between them are part of it.
test "a go code block may hold several lines" {
  assert_eq(parse("{{ let x = 1\nlet y = 2 }}"), [
    GoCode("let x = 1\nlet y = 2"),
  ])
}

///|
test "an empty go code block holds nothing" {
  assert_eq(parse("{{ }}"), [GoCode("")])
  assert_eq(parse("{{}}"), [GoCode("")])
}

///|
/// A block is a node among others.
test "a go code block is a node among others" {
  assert_eq(parse("<div>{{ let x = 1 }}</div>"), [
    el("div", [GoCode("let x = 1")], false),
  ])
}

///|
/// `a` and `{{ x := 1 }}` are two nodes whether or not a space separates them: a
/// `{` always opens one, the way a `<` always opens a tag.
test "a go code block follows text" {
  assert_eq(parse("a{{ let x = 1 }}"), [Text("a"), GoCode("let x = 1")])
  assert_eq(parse("a {{ let x = 1 }}"), [Text("a "), GoCode("let x = 1")])
}

///|
/// templ reads the whitespace that follows `}}` into the block and never writes it
/// out again, so a block swallows the run after it — the one place in templ where
/// whitespace between two nodes is simply lost.
test "a go code block eats the whitespace after it" {
  assert_eq(parse("a{{ let x = 1 }} c"), [
    Text("a"),
    GoCode("let x = 1"),
    Text("c"),
  ])
  assert_eq(parse("{{ let x = 1 }}\n<p>a</p>"), [
    GoCode("let x = 1"),
    el("p", [Text("a")], false),
  ])
}

///|
/// The whitespace before `{{` is not the block's: it belongs to the text node it
/// was read into, and survives there.
test "a go code block keeps the whitespace before it in the text" {
  assert_eq(parse("a {{ let x = 1 }} c"), [
    Text("a "),
    GoCode("let x = 1"),
    Text("c"),
  ])
}

///|
/// Braces and markers inside the code do not close the block: what it holds is
/// whatever MoonBit would read as one statement, so a `}` inside a string or a
/// nested `{ ... }` is part of it.
test "a go code block may hold braces and strings" {
  assert_eq(parse("{{ let m = { \"a\": 1 } }}"), [
    GoCode("let m = { \"a\": 1 }"),
  ])
  assert_eq(parse("{{ f(\"}}\") }}"), [GoCode("f(\"}}\")")])
}

///|
/// A block nests inside the bodies of the statements around it, and inside an
/// element's children.
test "a go code block nests like any other node" {
  assert_eq(parse("if a {\n{{ let x = 1 }}\n}"), [
    If({ condition: "a", then: [GoCode("let x = 1")], else_ifs: [], else_: [], }),
  ])
}

///|
test "a go code block needs its closing braces" {
  assert_eq(
    error_of("{{ let x = 1 }"),
    @parser.ParseError(
      offset=0,
      message="go code: missing '}}' to close the block",
    ),
  )
  assert_eq(
    error_of("{{ let x = 1"),
    @parser.ParseError(offset=0, message="unterminated expression"),
  )
}

///|
fn call(expression : String, children : Array[@parser.Node]) -> @parser.Node {
  Call({ expression, children, })
}

///|
test "a call with no arguments" {
  assert_eq(parse("@Card()"), [call("Card()", [])])
  assert_eq(parse("@card()"), [call("card()", [])])
}

///|
test "a call keeps its arguments verbatim" {
  assert_eq(parse("@Card(title)"), [call("Card(title)", [])])
  assert_eq(parse("@Card(title, 1)"), [call("Card(title, 1)", [])])
  assert_eq(parse("@Card(f(a, b))"), [call("Card(f(a, b))", [])])
}

///|
/// A package-qualified call is spelled the way MoonBit spells the reference:
/// the one `@` marks the call and stands for the package.
test "a package-qualified call is spelled with one marker" {
  assert_eq(parse("@ui.Card(title)"), [call("@ui.Card(title)", [])])
  assert_eq(parse("@ui.card()"), [call("@ui.card()", [])])
}

///|
test "a call expression reaches through fields and indexes" {
  assert_eq(parse("@cards[i].first()"), [call("cards[i].first()", [])])
  assert_eq(parse("@cards[i]"), [call("cards[i]", [])])
  assert_eq(parse("@Card(x)::render()"), [call("Card(x)::render()", [])])
}

///|
test "brackets and strings inside an argument nest" {
  assert_eq(parse("@f(a[0], g(b))"), [call("f(a[0], g(b))", [])])
  assert_eq(parse("@f(\")\")"), [call("f(\")\")", [])])
  assert_eq(parse("@f(x[1 + (2)])"), [call("f(x[1 + (2)])", [])])
}

///|
test "a children block holds nodes" {
  assert_eq(parse("@Card() { x }"), [call("Card()", [Text("x"), Text(" ")])])
  assert_eq(parse("@Card(){x}"), [call("Card()", [Text("x")])])
  assert_eq(parse("@Card() { <b>x</b> }"), [
    call("Card()", [
      Element({
        name: "b",
        attrs: [],
        children: [Text("x")],
        self_closing: false,
        indent_attrs: false,
        indent_children: false,
      }),
    ]),
  ])
}

///|
test "a block with nothing in it leaves no children" {
  assert_eq(parse("@Card(){}"), [call("Card()", [])])
  assert_eq(parse("@Card() { }"), [call("Card()", [])])
  assert_eq(parse("@Card() {\n  \n}"), [call("Card()", [])])
}

///|
test "children are normalized like any other node list" {
  assert_eq(parse("@Card() { a @b() c }"), [
    call("Card()", [
      Text("a"),
      Text(" "),
      call("b()", []),
      Text(" "),
      Text("c"),
      Text(" "),
    ]),
  ])
  assert_eq(parse("@Card() { a\nb }"), [
    call("Card()", [Text("a"), Text(" "), Text("b"), Text(" ")]),
  ])
}

///|
test "a call nests inside a call" {
  assert_eq(parse("@A() { @B() }"), [call("A()", [call("B()", [])])])
}

///|
/// A newline before the brace puts it on a line of its own, where it is an
/// expression rather than a block of children.
test "a brace on its own line is an expression, not children" {
  assert_eq(parse("@Card()\n{ x }"), [
    call("Card()", []),
    Text("\n"),
    StringExpression(" x "),
  ])
}

///|
test "whitespace before a call leaves the text to end earlier" {
  assert_eq(parse("a @c()"), [Text("a"), Text(" "), call("c()", [])])
  assert_eq(parse("a  @c()"), [Text("a "), Text(" "), call("c()", [])])
  assert_eq(parse("a\t@c()"), [Text("a"), Text("\t"), call("c()", [])])
  assert_eq(parse("\n@c()"), [Text("\n"), call("c()", [])])
}

///|
/// Only whitespace separates a call from the text before it: an `@` with a word
/// in front of it is text, and so is one with a word behind it.
test "an @ inside a word is text" {
  assert_eq(parse("a@c()"), [Text("a@c()")])
  assert_eq(parse("@c()x"), [call("c()", []), Text("x")])
  assert_eq(parse("user@example.com"), [Text("user@example.com")])
}

///|
test "a call sits between elements like any other node" {
  assert_eq(parse("<p>a @c() b</p>"), [
    el("p", [Text("a"), Text(" "), call("c()", []), Text(" b")], false),
  ])
}

///|
test "a call with no name is an error" {
  assert_eq(
    error_of("@"),
    @parser.ParseError(offset=0, message="expected a component name after '@'"),
  )
  assert_eq(
    error_of("@{}"),
    @parser.ParseError(offset=0, message="expected a component name after '@'"),
  )
}

///|
test "an unterminated call is an error" {
  assert_eq(
    error_of("@Card("),
    @parser.ParseError(
      offset=0,
      message="expected ')' to close a component call",
    ),
  )
}

///|
test "an unterminated children block is an error" {
  assert_eq(
    error_of("@Card() { x"),
    @parser.ParseError(offset=0, message="@Card(): missing end (expected '}')"),
  )
}

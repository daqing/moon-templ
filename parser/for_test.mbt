///|
fn for_node(
  expression : String,
  children : Array[@parser.Node],
) -> @parser.Node {
  For({ expression, children, })
}

///|
/// Both of MoonBit's loops are templ's, and both keep their head as it stands:
/// nothing here reads it, and the generated file is where it is checked.
test "a for holds its head and its block" {
  assert_eq(parse("for i, v in items {\n<i>c</i>\n}"), [
    for_node("i, v in items", [el("i", [Text("c")], false), Text("\n")]),
  ])
  assert_eq(parse("for i = 0; i < n; i = i + 1 {\n<i>c</i>\n}"), [
    for_node("i = 0; i < n; i = i + 1", [
      el("i", [Text("c")], false),
      Text("\n"),
    ]),
  ])
  assert_eq(parse("for v in f(a, b) {\nx\n}"), [
    for_node("v in f(a, b)", [Text("x\n")]),
  ])
}

///|
/// A loop ends where its block does, so what follows the closing brace is the
/// next node of the list.
test "a loop is a node among others" {
  assert_eq(parse("for v in items {\n<i>c</i>\n}x"), [
    for_node("v in items", [el("i", [Text("c")], false), Text("\n")]),
    Text("x"),
  ])
  assert_eq(parse("<p>a</p>\nfor v in items {\n<i>c</i>\n}"), [
    el("p", [Text("a")], false),
    Text("\n"),
    for_node("v in items", [el("i", [Text("c")], false), Text("\n")]),
  ])
}

///|
/// The keyword needs both the space after it and the newline after its brace, so a
/// loop that follows a node on the same line still starts there: the whitespace
/// between them belongs to the node before it, so nothing stands between the
/// keyword and the start of the line.
test "a loop may follow a node on the same line" {
  assert_eq(parse("<i>a</i> for v in items {\nb\n}"), [
    el("i", [Text("a")], false),
    Text(" "),
    for_node("v in items", [Text("b\n")]),
  ])
}

///|
test "for in the middle of a line of text is text" {
  assert_eq(parse("a for v in items {\nc\n}"), [
    Text("a for v in items "),
    StringExpression("\nc\n"),
  ])
}

///|
test "a loop nests inside a loop" {
  assert_eq(parse("for v in items {\nfor w in v {\nx\n}\n}"), [
    for_node("v in items", [for_node("w in v", [Text("x\n")]), Text("\n")]),
  ])
}

///|
/// Normalizing reaches into the body, which is a block body: the whitespace that
/// leads and trails it goes, and what is left of the statement's own trailing
/// whitespace is the list's business, not the node's.
test "normalizing a loop normalizes its body" {
  assert_eq(
    @parser.normalize_whitespace(
      parse("<div>\nfor v in items {\n<i>c</i>\n}\ntext\n</div>"),
    ),
    [
      el(
        "div",
        [
          for_node("v in items", [el("i", [Text("c")], false), Text(" ")]),
          Text("text"),
        ],
        false,
        indent_children=true,
      ),
    ],
  )
}

///|
test "a loop's brace has to open the block on a line of its own" {
  assert_eq(
    message_of("for v in items { x\n}"),
    "for: expected a newline after '{', so that the block starts on a line of its own",
  )
}

///|
test "a loop needs a head and a brace" {
  assert_eq(
    message_of("for  {\nx\n}"),
    "for: expected a loop expression before '{'",
  )
  assert_eq(message_of("for x\n"), "for: missing '{' after the loop expression")
}

///|
test "an unclosed loop body is an error" {
  assert_eq(
    message_of("for v in items {\n<i>c</i>\n"),
    "for: expected '}' to close the block",
  )
}

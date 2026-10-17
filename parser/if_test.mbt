///|
fn if_node(
  condition : String,
  then_ : Array[@parser.Node],
  else_ifs : Array[@parser.ElseIf],
  else_ : Array[@parser.Node],
) -> @parser.Node {
  If({ condition, then: then_, else_ifs, else_, })
}

///|
fn else_if(condition : String, then_ : Array[@parser.Node]) -> @parser.ElseIf {
  { condition, then: then_, }
}

///|
/// The message an error carries. Where it points is another matter: the offset is
/// the head of the branch being read, and `parse` reports it as it goes.
fn message_of(src : String) -> String {
  match error_of(src) {
    @parser.ParseError(message~, ..) => message
  }
}

///|
/// The condition is copied through as it stands, whatever it holds: nothing here
/// reads it, and the generated file is where it is checked.
test "an if holds its condition and its block" {
  assert_eq(parse("if x == \"a\" {\n<i>c</i>\n}"), [
    if_node("x == \"a\"", [el("i", [Text("c")], false), Text("\n")], [], []),
  ])
  assert_eq(parse("if x>1 && y {\n<i>c</i>\n}"), [
    if_node("x>1 && y", [el("i", [Text("c")], false), Text("\n")], [], []),
  ])
  assert_eq(parse("if f(a, b) {\nx\n}"), [
    if_node("f(a, b)", [Text("x\n")], [], []),
  ])
}

///|
/// A statement ends where its block does, so what follows the closing brace is
/// the next node of the list.
test "a statement is a node among others" {
  assert_eq(parse("if x {\n<i>c</i>\n}x"), [
    if_node("x", [el("i", [Text("c")], false), Text("\n")], [], []),
    Text("x"),
  ])
  assert_eq(parse("<p>a</p>\nif x {\n<i>c</i>\n}"), [
    el("p", [Text("a")], false),
    Text("\n"),
    if_node("x", [el("i", [Text("c")], false), Text("\n")], [], []),
  ])
}

///|
/// A statement that follows a node on the same line still starts there: the
/// whitespace between them belongs to the node before it, so nothing stands
/// between the keyword and the start of the line.
test "a statement may follow a node on the same line" {
  assert_eq(parse("<i>a</i> if x {\nb\n}"), [
    el("i", [Text("a")], false),
    Text(" "),
    if_node("x", [Text("b\n")], [], []),
  ])
}

///|
/// The keyword needs both the space after it and the newline after its brace, so
/// a line of prose that opens with `if` stays prose.
test "if in the middle of a line of text is text" {
  assert_eq(parse("a if x == \"b\" {\nc\n}"), [
    Text("a if x == \"b\" "),
    StringExpression("\nc\n"),
  ])
}

///|
test "an if carries its else if chain and its else" {
  assert_eq(parse("if a {\nx\n} else if b {\ny\n} else {\nz\n}"), [
    if_node("a", [Text("x\n")], [else_if("b", [Text("y\n")])], [Text("z\n")]),
  ])
  assert_eq(parse("if a {\nx\n} else if b {\ny\n} else if c {\nz\n}"), [
    if_node(
      "a",
      [Text("x\n")],
      [else_if("b", [Text("y\n")]), else_if("c", [Text("z\n")])],
      [],
    ),
  ])
}

///|
/// The whitespace around a branch's braces may be anything, and an `else if` may
/// stand right against its condition — templ re-reads the head from the `if` on.
test "a branch takes any whitespace around its braces" {
  assert_eq(parse("if a {\nx\n}\nelse if b {\ny\n}\nelse {\nz\n}"), [
    if_node("a", [Text("x\n")], [else_if("b", [Text("y\n")])], [Text("z\n")]),
  ])
  assert_eq(parse("if a(x) {\nx\n} else if(b) {\ny\n} else{\nz\n}"), [
    if_node("a(x)", [Text("x\n")], [else_if("(b)", [Text("y\n")])], [
      Text("z\n"),
    ]),
  ])
}

///|
/// Only the heads of a statement have to open their block on a line of its own.
/// An else reads its body as an ordinary node list, so `else {` may carry on.
test "an else block needs no newline after its brace" {
  assert_eq(parse("if a {\nx\n} else { y\n}"), [
    if_node("a", [Text("x\n")], [], [Text("y\n")]),
  ])
}

///|
/// Only a brace opens an else block, so a statement without one simply has no
/// else: templ leaves the keyword where it stands and reads on.
test "an else that opens no block is text" {
  assert_eq(parse("if a {\nx\n} else"), [
    if_node("a", [Text("x\n")], [], []),
    Text(" else"),
  ])
  assert_eq(parse("if a {\nx\n} else b"), [
    if_node("a", [Text("x\n")], [], []),
    Text(" else b"),
  ])
}

///|
test "a statement nests inside a statement" {
  assert_eq(parse("if a {\nif b {\nx\n}\n}"), [
    if_node("a", [if_node("b", [Text("x\n")], [], []), Text("\n")], [], []),
  ])
}

///|
/// Normalizing reaches into every branch, and a branch is a block body: the
/// whitespace that leads and trails it goes, and what is left of the statement's
/// own trailing whitespace is the list's business, not the node's.
test "normalizing an if normalizes every branch" {
  assert_eq(
    @parser.normalize_whitespace(
      parse("<div>\nif x {\n<i>c</i>\n}\ntext\n</div>"),
    ),
    [
      el(
        "div",
        [
          if_node("x", [el("i", [Text("c")], false), Text(" ")], [], []),
          Text("text"),
        ],
        false,
        indent_children=true,
      ),
    ],
  )
}

///|
test "a brace has to open the block on a line of its own" {
  assert_eq(
    message_of("if x { y\n}"),
    "if: expected a newline after '{', so that the block starts on a line of its own",
  )
  assert_eq(
    message_of("if x {\n<i>c</i>\n} else if y { z\n}"),
    "if: expected a newline after '{', so that the block starts on a line of its own",
  )
}

///|
test "a statement needs a condition and a brace" {
  assert_eq(message_of("if  {\nx\n}"), "if: expected a condition before '{'")
  assert_eq(message_of("if x\n"), "if: missing '{' after the condition")
}

///|
test "an unclosed block is an error" {
  assert_eq(
    message_of("if x {\n<i>c</i>\n"),
    "if: expected '}' to close the block",
  )
}

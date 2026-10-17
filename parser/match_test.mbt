///|
fn match_node(subject : String, arms : Array[@parser.MatchArm]) -> @parser.Node {
  Match({ subject, arms, })
}

///|
fn arm(pattern : String, children : Array[@parser.Node]) -> @parser.MatchArm {
  { pattern, children, }
}

///|
/// The subject and every pattern are copied through as they stand: nothing here
/// reads them, and the generated file is where the compiler checks them.
test "a match holds its subject and its arms" {
  assert_eq(
    parse("match x {\n\"a\" => {\n<i>c</i>\n}\n_ => {\n<i>d</i>\n}\n}"),
    [
      match_node("x", [
        arm("\"a\"", [el("i", [Text("c")], false), Text("\n")]),
        arm("_", [el("i", [Text("d")], false), Text("\n")]),
      ]),
    ],
  )
  assert_eq(parse("match f(a, b) {\n0 => {\nx\n}\n}"), [
    match_node("f(a, b)", [arm("0", [Text("x\n")])]),
  ])
}

///|
/// A pattern is MoonBit's, so it may destructure and may name the variables its
/// arm reads — which is what templ's Go `switch` cannot do.
test "a pattern may destructure" {
  assert_eq(
    parse("match opt {\nSome(v) => {\n<i>c</i>\n}\nNone => {\nx\n}\n}"),
    [
      match_node("opt", [
        arm("Some(v)", [el("i", [Text("c")], false), Text("\n")]),
        arm("None", [Text("x\n")]),
      ]),
    ],
  )
  assert_eq(parse("match p {\nPoint::{ x, y } => {\n<i>c</i>\n}\n}"), [
    match_node("p", [
      arm("Point::{ x, y }", [el("i", [Text("c")], false), Text("\n")]),
    ]),
  ])
}

///|
/// A marker inside a pattern's own string is part of the pattern, so an arm whose
/// pattern holds `=>` is still read as one arm.
test "an arrow inside a pattern's string does not end the pattern" {
  assert_eq(parse("match x {\n\"a=>b\" => {\n<i>c</i>\n}\n}"), [
    match_node("x", [arm("\"a=>b\"", [el("i", [Text("c")], false), Text("\n")])]),
  ])
}

///|
/// A statement ends where its block does, so what follows the closing brace is
/// the next node of the list.
test "a match is a node among others" {
  assert_eq(parse("match x {\n\"a\" => {\nx\n}\n}y"), [
    match_node("x", [arm("\"a\"", [Text("x\n")])]),
    Text("y"),
  ])
  assert_eq(parse("<p>a</p>\nmatch x {\n\"a\" => {\nx\n}\n}"), [
    el("p", [Text("a")], false),
    Text("\n"),
    match_node("x", [arm("\"a\"", [Text("x\n")])]),
  ])
}

///|
test "a match may follow a node on the same line" {
  assert_eq(parse("<i>a</i> match x {\n\"a\" => {\nb\n}\n}"), [
    el("i", [Text("a")], false),
    Text(" "),
    match_node("x", [arm("\"a\"", [Text("b\n")])]),
  ])
}

///|
test "match in the middle of a line of text is text" {
  assert_eq(parse("a match x {\n\"a\" => {\nc\n}\n}"), [
    Text("a match x "),
    StringExpression("\n\"a\" => {\nc\n}\n"),
  ])
}

///|
test "a match nests inside an arm" {
  assert_eq(
    parse("match x {\n\"a\" => {\nmatch y {\n\"b\" => {\nx\n}\n}\n}\n}"),
    [
      match_node("x", [
        arm("\"a\"", [
          match_node("y", [arm("\"b\"", [Text("x\n")])]),
          Text("\n"),
        ]),
      ]),
    ],
  )
}

///|
/// Normalizing reaches into every arm, and an arm is a block body: the whitespace
/// that leads and trails it goes, and what is left of the statement's own trailing
/// whitespace is the list's business, not the node's.
test "normalizing a match normalizes every arm" {
  assert_eq(
    @parser.normalize_whitespace(
      parse("<div>\nmatch x {\n\"a\" => {\n<i>c</i>\n}\n}\ntext\n</div>"),
    ),
    [
      el(
        "div",
        [
          match_node("x", [
            arm("\"a\"", [el("i", [Text("c")], false), Text(" ")]),
          ]),
          Text("text"),
        ],
        false,
        indent_children=true,
      ),
    ],
  )
}

///|
test "a match needs a subject and a brace" {
  assert_eq(
    message_of("match  {\nx\n}"),
    "match: expected a subject before '{'",
  )
  assert_eq(message_of("match x\n"), "match: missing '{' after the subject")
}

///|
test "an arm needs a pattern, an arrow and a block" {
  assert_eq(
    message_of("match x {\n=> {\n<i>c</i>\n}\n}"),
    "match: expected a pattern before '=>'",
  )
  assert_eq(
    message_of("match x {\nx\n}"),
    "match: missing '=>' after the pattern",
  )
  assert_eq(
    message_of("match x {\n\"a\" => <i>c</i>\n}"),
    "match: expected '{' after '=>', so that the arm holds a block of nodes",
  )
  assert_eq(
    message_of("match x {\n\"a\" => { <i>c</i>\n}\n}"),
    "match: expected a newline after '{', so that the block starts on a line of its own",
  )
}

///|
test "an unclosed match is an error" {
  assert_eq(
    message_of("match x {\n\"a\" => {\n<i>c</i>\n}\n"),
    "match: expected '}' to close the block",
  )
  assert_eq(
    message_of("match x {\n\"a\" => {\n<i>c</i>\n"),
    "match: expected '}' to close the block",
  )
}

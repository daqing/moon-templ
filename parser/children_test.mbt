///|
test "a children expression is read whole" {
  assert_eq(parse("{ children... }"), [ChildrenExpression])
  assert_eq(parse("{children...}"), [ChildrenExpression])
  assert_eq(parse("{  children...  }"), [ChildrenExpression])
}

///|
/// The braces may be padded with any whitespace, a newline included.
test "a children expression may sit on its own lines" {
  assert_eq(parse("{\nchildren...\n}"), [ChildrenExpression])
  assert_eq(parse("{\n\tchildren...\n\t}"), [ChildrenExpression])
  assert_eq(parse("{\tchildren...\t}"), [ChildrenExpression])
}

///|
/// `children...` is not an expression anyone could write, so the braces have to
/// hold it and nothing else to be read as one.
test "the keyword has to stand alone inside the braces" {
  assert_eq(parse("{ children }"), [StringExpression(" children ")])
  assert_eq(parse("{ children.. }"), [StringExpression(" children.. ")])
  assert_eq(parse("{ children.... }"), [StringExpression(" children.... ")])
  assert_eq(parse("{ child... }"), [StringExpression(" child... ")])
  assert_eq(parse("{ children...x }"), [StringExpression(" children...x ")])
}

///|
test "a children expression stands among other nodes" {
  assert_eq(parse("{ children... }x"), [ChildrenExpression, Text("x")])
  assert_eq(parse("x{ children... }"), [Text("x"), ChildrenExpression])
  assert_eq(parse("<p>{ children... }</p>"), [
    el("p", [ChildrenExpression], false),
  ])
}

///|
/// A block belongs to the call it opens, so a children expression inside one is
/// that block's node, not the template's.
test "a children expression nests inside a call" {
  assert_eq(parse("@Card() { { children... } }"), [
    call("Card()", [ChildrenExpression]),
  ])
  assert_eq(parse("@Card() { <p>{ children... }</p> }"), [
    call("Card()", [el("p", [ChildrenExpression], false)]),
  ])
}

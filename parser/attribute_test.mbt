///|
fn element_of(src : String) -> @parser.Element raise @parser.ParseError {
  match parse(src) {
    [Element(e)] => e
    _ => raise @parser.ParseError(offset=0, message="expected a single element")
  }
}

///|
fn attrs_of(src : String) -> Array[@parser.Attribute] raise @parser.ParseError {
  element_of(src).attrs
}

///|
fn constant(name : String, value : String) -> @parser.Attribute {
  Constant(name~, value~)
}

///|
test "double quoted value" {
  assert_eq(attrs_of("<div a=\"1\"></div>"), [constant("a", "1")])
}

///|
test "single quoted value" {
  assert_eq(attrs_of("<div a='1'></div>"), [constant("a", "1")])
}

///|
test "unquoted value" {
  assert_eq(attrs_of("<div a=1></div>"), [constant("a", "1")])
}

///|
test "bare attribute is boolean" {
  assert_eq(attrs_of("<div disabled></div>"), [Bool(name="disabled")])
}

///|
test "mixed attributes keep their order" {
  assert_eq(attrs_of("<input type=\"text\" disabled required>"), [
    constant("type", "text"),
    Bool(name="disabled"),
    Bool(name="required"),
  ])
}

///|
test "attribute name charset" {
  assert_eq(attrs_of("<div @click='x' :class='y'></div>"), [
    constant("@click", "x"),
    constant(":class", "y"),
  ])
  assert_eq(attrs_of("<div x-on:click='x' data-a.b='y'></div>"), [
    constant("x-on:click", "x"),
    constant("data-a.b", "y"),
  ])
}

///|
test "quoted values may contain spaces and angle brackets" {
  assert_eq(attrs_of("<div a=\"x y\"></div>"), [constant("a", "x y")])
  assert_eq(attrs_of("<div a=\"x>y\"></div>"), [constant("a", "x>y")])
  assert_eq(attrs_of("<div a='x\"y'></div>"), [constant("a", "x\"y")])
}

///|
test "an empty quoted value is allowed" {
  assert_eq(attrs_of("<div a=\"\"></div>"), [constant("a", "")])
}

///|
test "a self-closing tag still parses its attributes" {
  let el = element_of("<img src=\"x\"/>")
  assert_eq(el.attrs, [constant("src", "x")])
  assert_true(el.self_closing)
}

///|
test "a void element still parses its attributes" {
  assert_eq(attrs_of("<img src=\"x\">"), [constant("src", "x")])
}

///|
test "an unquoted value ends at whitespace" {
  assert_eq(
    error_of("<div a=1 2></div>"),
    @parser.ParseError(offset=0, message="expected attribute name, found '2'"),
  )
}

///|
test "an empty value is an error" {
  assert_eq(
    error_of("<div a=></div>"),
    @parser.ParseError(offset=0, message="expected attribute value"),
  )
}

///|
fn expression(name : String, value : String) -> @parser.Attribute {
  Expression(name~, value~)
}

///|
test "expression attribute value" {
  assert_eq(attrs_of("<div a={ x }></div>"), [expression("a", " x ")])
}

///|
test "expression attribute value keeps the expression verbatim" {
  assert_eq(attrs_of("<div a={ f(\"}\", 1) }></div>"), [
    expression("a", " f(\"}\", 1) "),
  ])
  assert_eq(attrs_of("<div a={ x }b={ y }></div>"), [
    expression("a", " x "),
    expression("b", " y "),
  ])
}

///|
test "expression attribute values mix with the other forms" {
  assert_eq(attrs_of("<input type=\"text\" value={ v } disabled>"), [
    constant("type", "text"),
    expression("value", " v "),
    Bool(name="disabled"),
  ])
}

///|
test "an unterminated expression attribute value is an error" {
  assert_eq(
    error_of("<div a={ x ></div>"),
    @parser.ParseError(offset=0, message="unterminated expression"),
  )
}

///|
fn spread(value : String) -> @parser.Attribute {
  Spread(value~)
}

///|
test "an attribute spread keeps the expression it spreads" {
  assert_eq(attrs_of("<div { attrs... }></div>"), [spread("attrs")])
  assert_eq(attrs_of("<div { self.attrs... }></div>"), [spread("self.attrs")])
  assert_eq(attrs_of("<div { f(a, b)... }></div>"), [spread("f(a, b)")])
}

///|
test "an attribute spread mixes with the other forms" {
  assert_eq(attrs_of("<div id=\"a\" { attrs... } class={ c }></div>"), [
    constant("id", "a"),
    spread("attrs"),
    expression("class", " c "),
  ])
  assert_eq(attrs_of("<div {a...}></div>"), [spread("a")])
}

///|
/// The `...` ends the expression rather than the braces, so whitespace may pad it
/// without changing what it spreads.
test "an attribute spread trims around the marker" {
  assert_eq(attrs_of("<div { attrs ... }></div>"), [spread("attrs")])
  assert_eq(attrs_of("<div {\n  attrs...\n}></div>"), [spread("attrs")])
}

///|
test "an attribute spread needs an expression and a marker" {
  assert_eq(
    error_of("<div { attrs }></div>"),
    @parser.ParseError(
      offset=0,
      message="an attribute spread needs `...`, as in `{ attrs... }`",
    ),
  )
  assert_eq(
    error_of("<div { ... }></div>"),
    @parser.ParseError(
      offset=0,
      message="an attribute spread needs an expression: `{ ... }`",
    ),
  )
}

///|
test "an unterminated attribute spread is an error" {
  assert_eq(
    error_of("<div { attrs... ></div>"),
    @parser.ParseError(offset=0, message="unterminated expression"),
  )
}

///|
/// `name?={ expr }` is the form `name` and `name={ expr }` do not cover: the
/// attribute is the same one either way, and what the expression decides is
/// whether it is written at all.
test "boolean expression attribute" {
  assert_eq(attrs_of("<div a?={ x }></div>"), [
    BoolExpression(name="a", value=" x "),
  ])
  assert_eq(attrs_of("<div a?={x}></div>"), [
    BoolExpression(name="a", value="x"),
  ])
  assert_eq(attrs_of("<div a={ x } a2?={ y }></div>"), [
    expression("a", " x "),
    BoolExpression(name="a2", value=" y "),
  ])
}

///|
/// The `?=` has to be followed by an expression in braces, and the braces have to
/// close: a `?` on its own is not the form, and an expression that runs off the
/// end of the tag is not one either.
test "a boolean expression attribute needs its expression" {
  assert_eq(
    error_of("<div a?={ x ></div>"),
    @parser.ParseError(offset=0, message="unterminated expression"),
  )
  assert_eq(
    error_of("<div a?{ x }></div>"),
    @parser.ParseError(
      offset=0,
      message="a boolean expression attribute is written `a?={ expr }`",
    ),
  )
  assert_eq(
    error_of("<div a?=\"x\"></div>"),
    @parser.ParseError(
      offset=0,
      message="a boolean expression attribute is written `a?={ expr }`",
    ),
  )
}

///|
fn conditional(
  condition : String,
  then : Array[@parser.Attribute],
  else_ : Array[@parser.Attribute],
) -> @parser.Attribute {
  Conditional(condition~, then~, else_~)
}

///|
/// `if expr { attrs }` inside a start tag: which attributes the tag carries is
/// what the expression decides, and a block with no `else` simply carries none
/// when the condition is false.
test "conditional attribute" {
  assert_eq(attrs_of("<div if x { class=\"a\" }></div>"), [
    conditional("x", [constant("class", "a")], []),
  ])
  assert_eq(attrs_of("<div if x { class=\"a\" } else { class=\"b\" }></div>"), [
    conditional("x", [constant("class", "a")], [constant("class", "b")]),
  ])
}

///|
/// The condition is copied through the way a block head is, so it may be any
/// expression MoonBit writes — boolean operators, calls, braces of its own, which
/// the head scan steps over rather than ends at.
test "a conditional attribute copies its condition" {
  assert_eq(attrs_of("<div if a && !b { class=\"a\" }></div>"), [
    conditional("a && !b", [constant("class", "a")], []),
  ])
  assert_eq(attrs_of("<div if f({ x: 1 }) { class=\"a\" }></div>"), [
    conditional("f({ x: 1 })", [constant("class", "a")], []),
  ])
}

///|
/// A block holds attributes, and an attribute list holds every form an attribute
/// takes: a boolean, an expression, a spread, and a conditional inside a
/// conditional.
test "a conditional attribute holds every form of attribute" {
  assert_eq(
    attrs_of(
      "<div if x { class=\"a\" hidden if y { title=\"t\" } { attrs... } }></div>",
    ),
    [
      conditional(
        "x",
        [
          constant("class", "a"),
          Bool(name="hidden"),
          conditional("y", [constant("title", "t")], []),
          spread("attrs"),
        ],
        [],
      ),
    ],
  )
}

///|
/// A conditional attribute is one of the list like any other, and the attributes
/// around it are none of its business.
test "a conditional attribute stands among the others" {
  assert_eq(
    attrs_of("<div id=\"a\" if x { class=\"b\" } data-k=\"c\"></div>"),
    [
      constant("id", "a"),
      conditional("x", [constant("class", "b")], []),
      constant("data-k", "c"),
    ],
  )
}

///|
/// `if` on its own is an attribute of that name — the marker is the space, as it
/// is in templ, so `if="x"` is a value and not a block.
test "an attribute named if is not a conditional one" {
  assert_eq(attrs_of("<div if=\"x\"></div>"), [constant("if", "x")])
  assert_eq(attrs_of("<div if></div>"), [Bool(name="if")])
}

///|
/// The head reads to the `{` that opens the block, so a condition that runs off
/// the end of the tag is an error rather than a condition with the rest of the
/// file in it.
test "a conditional attribute needs a condition and a block" {
  assert_eq(
    error_of("<div if x class=\"a\"></div>"),
    @parser.ParseError(offset=0, message="if: missing '{' after the condition"),
  )
  assert_eq(
    error_of("<div if { class=\"a\" }></div>"),
    @parser.ParseError(offset=0, message="if: expected a condition before '{'"),
  )
}

///|
/// templ reads the head with its Go parser, which wants the brace on the line the
/// condition is on; the newline after the brace is the other way round, since
/// what follows is an attribute list rather than a node list, so a branch may sit
/// on one line.
test "a conditional attribute keeps its brace on the condition's line" {
  assert_eq(
    error_of("<div if x\n{ class=\"a\" }></div>"),
    @parser.ParseError(
      offset=0,
      message="if: expected '{' on the line the condition is on",
    ),
  )
  assert_eq(attrs_of("<div if x {\n  class=\"a\"\n}></div>"), [
    conditional("x", [constant("class", "a")], []),
  ])
}

///|
/// A branch with nothing in it says nothing, so it is not a branch templ accepts
/// — and neither does the port.
test "an empty conditional attribute block is an error" {
  assert_eq(
    error_of("<div if x { }></div>"),
    @parser.ParseError(
      offset=0,
      message="if: expected attributes in the block, but none were found",
    ),
  )
  assert_eq(
    error_of("<div if x { class=\"a\" } else { }></div>"),
    @parser.ParseError(
      offset=0,
      message="else: expected attributes in the block, but none were found",
    ),
  )
}

///|
/// An attribute block has no `else if`: templ reads one as an `else` attribute
/// and a second `if`, which renders the word `else` into the tag, so the port
/// refuses it rather than write that.
test "an else if in an attribute block is refused" {
  assert_eq(
    error_of("<div if x { class=\"a\" } else if y { class=\"b\" }></div>"),
    @parser.ParseError(
      offset=0,
      message="else: expected '{' after it, since an attribute block has no `else if`",
    ),
  )
}

///|
/// The `}` that closes a branch is where the block ends, and a block that never
/// reaches one is an error rather than an attribute list that eats the rest of
/// the file.
test "an unterminated conditional attribute block is an error" {
  assert_eq(
    error_of("<div if x { class=\"a\">"),
    @parser.ParseError(offset=0, message="if: missing '}' to close the block"),
  )
  assert_eq(
    error_of("<div if x { class=\"a\" } else { class=\"b\">"),
    @parser.ParseError(offset=0, message="else: missing '}' to close the block"),
  )
}

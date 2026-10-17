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

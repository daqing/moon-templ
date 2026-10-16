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
test "expression attribute values are rejected for now" {
  assert_eq(
    error_of("<div a={ x }></div>"),
    @parser.ParseError(
      offset=0,
      message="expression attribute values are not supported yet: name={ ... }",
    ),
  )
}

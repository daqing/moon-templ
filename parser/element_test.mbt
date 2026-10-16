///|
fn el(
  name : String,
  children : Array[@parser.Node],
  self_closing : Bool,
) -> @parser.Node {
  Element({ name, attrs: [], children, self_closing, })
}

///|
fn parse(src : String) -> Array[@parser.Node] raise @parser.ParseError {
  let (nodes, rest) = @parser.parse_nodes(src[:], 0, fn(_) { false })
  if !rest.is_empty() {
    raise @parser.ParseError(
      offset=0,
      message="trailing input: " + rest.to_owned(),
    )
  }
  nodes
}

///|
fn error_of(src : String) -> @parser.ParseError {
  try parse(src) catch {
    e => e
  } noraise {
    _ => @parser.ParseError(offset=0, message="no error")
  }
}

///|
test "empty element" {
  assert_eq(parse("<div></div>"), [el("div", [], false)])
}

///|
test "element with a text child" {
  assert_eq(parse("<div>hello</div>"), [el("div", [Text("hello")], false)])
}

///|
test "nested elements" {
  assert_eq(parse("<div><span>x</span></div>"), [
    el("div", [el("span", [Text("x")], false)], false),
  ])
}

///|
test "siblings" {
  assert_eq(parse("<div></div><span></span>"), [
    el("div", [], false),
    el("span", [], false),
  ])
}

///|
test "self-closing tags" {
  assert_eq(parse("<br/>"), [el("br", [], true)])
  assert_eq(parse("<br />"), [el("br", [], true)])
  assert_eq(parse("<my-widget/>"), [el("my-widget", [], true)])
}

///|
test "void elements carry no children and need no close tag" {
  assert_eq(parse("<br>"), [el("br", [], false)])
  assert_eq(parse("<img>"), [el("img", [], false)])
  assert_eq(parse("<div><br><hr></div>"), [
    el("div", [el("br", [], false), el("hr", [], false)], false),
  ])
}

///|
test "element name charset" {
  assert_eq(parse("<h1></h1>"), [el("h1", [], false)])
  assert_eq(parse("<my-element></my-element>"), [el("my-element", [], false)])
  assert_eq(parse("<svg:rect></svg:rect>"), [el("svg:rect", [], false)])
  assert_eq(parse("<a2-b:c></a2-b:c>"), [el("a2-b:c", [], false)])
}

///|
test "uppercase element names are rejected" {
  assert_eq(
    error_of("<DIV></DIV>"),
    @parser.ParseError(
      offset=0,
      message="element name must start with a lowercase letter: D",
    ),
  )
}

///|
test "an unterminated start tag is an error" {
  assert_eq(
    error_of("<div"),
    @parser.ParseError(offset=0, message="unterminated start tag"),
  )
}

///|
test "an unclosed element is an error" {
  assert_eq(
    error_of("<div>text"),
    @parser.ParseError(offset=0, message="unclosed element <div>"),
  )
}

///|
test "an angle bracket inside a quoted attribute does not end the tag" {
  assert_eq(attrs_of("<img src=\"a>b\">"), [constant("src", "a>b")])
  assert_eq(attrs_of("<img src='a>b'>"), [constant("src", "a>b")])
}

///|
test "text runs until the next tag" {
  assert_eq(parse("hello"), [Text("hello")])
  assert_eq(parse("a<div>b</div>"), [Text("a"), el("div", [Text("b")], false)])
}

///|
test "text around an expression becomes separate nodes" {
  assert_eq(parse("Hello, { name }!"), [
    Text("Hello, "),
    StringExpression(" name "),
    Text("!"),
  ])
}

///|
test "a lone expression is a single node" {
  assert_eq(parse("{ x }"), [StringExpression(" x ")])
}

///|
/// A raw text element: its contents are not template syntax.
fn raw(name : String, contents : String) -> @parser.Node {
  RawElement({ name, attrs: [], contents, })
}

///|
test "style contents are taken verbatim" {
  assert_eq(parse("<style>a>b{}</style>"), [raw("style", "a>b{}")])
  assert_eq(parse("<style></style>"), [raw("style", "")])
}

///|
test "script contents are taken verbatim" {
  assert_eq(parse("<script>if (a<b) { go() }</script>"), [
    raw("script", "if (a<b) { go() }"),
  ])
}

///|
test "a raw element keeps its attributes" {
  assert_eq(parse("<style media=\"print\">a{}</style>"), [
    @parser.RawElement({
      name: "style",
      attrs: [@parser.Constant(name="media", value="print")],
      contents: "a{}",
    }),
  ])
}

///|
test "a raw element name that is only a prefix is an ordinary element" {
  assert_eq(parse("<scripts>hi</scripts>"), [el("scripts", [Text("hi")], false)])
  assert_eq(parse("<styles></styles>"), [el("styles", [], false)])
}

///|
test "a self-closing raw element name is not raw" {
  assert_eq(parse("<style/>"), [el("style", [], true)])
}

///|
test "an unclosed raw element is an error" {
  assert_eq(
    error_of("<style>a{}"),
    @parser.ParseError(
      offset=0,
      message="<style>: expected end tag not present",
    ),
  )
}

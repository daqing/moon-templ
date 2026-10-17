///|
test "ast values are constructible from outside the package" {
  let el : @parser.Element = {
    name: "div",
    attrs: [@parser.Constant(name="class", value="a")],
    children: [@parser.Text("hi"), @parser.StringExpression("name")],
    self_closing: false,
    indent_attrs: false,
    indent_children: false,
  }
  let t : @parser.Template = {
    name: "hello",
    receiver: "",
    params: "name : String",
    nodes: [
      @parser.Element(el),
      @parser.DocType("html"),
      @parser.HTMLComment("c"),
    ],
    start: 0,
    end: 0,
  }
  assert_eq(t.nodes.length(), 3)
  assert_eq(t.nodes[0], @parser.Element(el))
}

///|
test "boolean attribute holds just a name" {
  assert_eq(@parser.Bool(name="disabled"), @parser.Bool(name="disabled"))
  assert_true(@parser.Bool(name="disabled") is Bool(name="disabled"))
}

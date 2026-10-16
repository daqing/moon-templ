///|
fn only_template(src : String) -> @parser.Template raise @parser.ParseError {
  let file = @parser.parse_template_file(src)
  if file.templates.length() != 1 {
    raise @parser.ParseError(
      offset=0,
      message="expected exactly one template, got \{file.templates.length()}",
    )
  }
  file.templates[0]
}

///|
fn file_error_of(src : String) -> String {
  try @parser.parse_template_file(src) catch {
    @parser.ParseError(message~, ..) => message
  } noraise {
    _ => "<no error>"
  }
}

///|
test "a template without parameters" {
  let t = only_template("templ hello() {\n  <div>hi</div>\n}\n")
  assert_eq(t.name, "hello")
  assert_eq(t.receiver, "")
  assert_eq(t.params, "")
  assert_eq(t.nodes, [el("div", [Text("hi")], false)])
}

///|
test "a template with parameters keeps the source spelling" {
  let t = only_template(
    "templ greet(name : String, times : Int) {\n  <p>{ name }</p>\n}\n",
  )
  assert_eq(t.name, "greet")
  assert_eq(t.params, "name : String, times : Int")
  assert_eq(t.nodes, [el("p", [StringExpression(" name ")], false)])
}

///|
test "a method template keeps its receiver" {
  let t = only_template(
    "templ (self : Model) Greeting(name : String) {\n  <p>hi</p>\n}\n",
  )
  assert_eq(t.receiver, "self : Model")
  assert_eq(t.name, "Greeting")
  assert_eq(t.params, "name : String")
}

///|
test "parameter lists may nest parentheses and brackets" {
  let t = only_template("templ f(cb : (Int) -> Unit, xs : Array[Int]) {\n}\n")
  assert_eq(t.params, "cb : (Int) -> Unit, xs : Array[Int]")
  assert_eq(t.nodes, [])
}

///|
test "a bracket in the parameter list does not open the body" {
  let t = only_template("templ f(opts : Map[String, Int]) {\n  <br>\n}\n")
  assert_eq(t.params, "opts : Map[String, Int]")
  assert_eq(t.nodes.length(), 1)
}

///|
test "an empty body produces no nodes" {
  let t = only_template("templ empty() {}\n")
  assert_eq(t.nodes, [])
}

///|
test "several templates in one file" {
  let src =
    #|import { "moonbitlang/core/string" }
    #|
    #|templ a() {
    #|  <p>a</p>
    #|}
    #|
    #|// a comment
    #|let helper = 1
    #|
    #|templ b(name : String) {
    #|  <p>{ name }</p>
    #|}
    #|
  let file = @parser.parse_template_file(src)
  assert_eq(file.templates.length(), 2)
  assert_eq(file.templates[0].name, "a")
  assert_eq(file.templates[0].params, "")
  assert_eq(file.templates[1].name, "b")
  assert_eq(file.templates[1].params, "name : String")
}

///|
test "a file with no templ block yields no templates" {
  let file = @parser.parse_template_file("// nothing to see here\n")
  assert_eq(file.templates.length(), 0)
}

///|
test "`template` is not the `templ` keyword" {
  let file = @parser.parse_template_file("let template = 1\n")
  assert_eq(file.templates.length(), 0)
}

///|
test "whitespace around a template body is dropped" {
  let t = only_template("templ hello() {\n  <div>hi</div>\n}\n")
  assert_eq(t.nodes.length(), 1)
}

///|
test "the body ends at the matching brace, not the first one" {
  let t = only_template("templ hello(name : String) {\n  <p>{ name }</p>\n}\n")
  assert_eq(t.nodes.length(), 1)
}

///|
test "a missing body brace is an error" {
  assert_eq(
    file_error_of("templ hello()\n"),
    "unterminated template declaration: expected '{'",
  )
}

///|
test "an unclosed body is an error" {
  assert_eq(
    file_error_of("templ hello() {\n  <p>hi</p>\n"),
    "unclosed templ block: expected '}' to close hello",
  )
}

///|
test "a missing name is an error" {
  assert_eq(
    file_error_of("templ () {\n}\n"),
    "expected a template name after `templ`",
  )
}

///|
test "a missing parameter list is an error" {
  assert_eq(
    file_error_of("templ hello {\n}\n"),
    "expected a parameter list after the template name hello",
  )
}

///|
test "trailing text after the signature is an error" {
  assert_eq(
    file_error_of("templ hello() -> Unit {\n}\n"),
    "unexpected text after the template signature: -> Unit",
  )
}

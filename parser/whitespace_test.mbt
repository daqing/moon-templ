///|
fn is_void(name : String) -> Bool {
  match name {
    "area"
    | "base"
    | "br"
    | "col"
    | "embed"
    | "hr"
    | "img"
    | "input"
    | "link"
    | "meta"
    | "param"
    | "source"
    | "track"
    | "wbr" => true
    _ => false
  }
}

///|
/// Render a normalized node list, standing in for an expression with `§`. The
/// expected values below were captured from templ's own generator so that the
/// MoonBit rules stay byte-identical to the implementation being ported.
///
/// A call prints nothing: templ renders it by calling out to the component, so
/// the literals templ emits for a body are the ones around the call, and its
/// children's literals land where the call stands. Printing the children and
/// nothing else lines the two recordings up.
fn preview_nodes(nodes : Array[@parser.Node], buf : StringBuilder) -> Unit {
  for node in nodes {
    match node {
      Text(s) => buf.write_string(s)
      StringExpression(_) => buf.write_string("§")
      Call(call) => preview_nodes(call.children, buf)
      Element(e) => {
        buf.write_string("<" + e.name + ">")
        preview_nodes(e.children, buf)
        if !e.self_closing && !is_void(e.name) {
          buf.write_string("</" + e.name + ">")
        }
      }
      HTMLComment(_) => buf.write_string("<!---->")
      DocType(v) => buf.write_string("<!doctype " + v + ">")
      RawElement(e) => {
        buf.write_string("<" + e.name + ">")
        buf.write_string(e.contents)
        buf.write_string("</" + e.name + ">")
      }
    }
  }
}

///|
fn preview(src : String) -> String raise @parser.ParseError {
  let buf = StringBuilder()
  preview_nodes(@parser.normalize_whitespace(parse(src)), buf)
  buf.to_string()
}

///|
test "whitespace between inline nodes collapses to one space" {
  assert_eq(preview("<p>\n\tfoo\n\tbar\n</p>"), "<p>foo bar</p>")
  assert_eq(preview("<p>a\nb</p>"), "<p>a b</p>")
  assert_eq(preview("<p>a\n\n\nb</p>"), "<p>a b</p>")
}

///|
test "whitespace between block nodes is dropped" {
  assert_eq(
    preview("<div>\n  <p>a</p>\n  <p>b</p>\n</div>"),
    "<div><p>a</p><p>b</p></div>",
  )
  assert_eq(preview("<p>a</p>\n<p>b</p>"), "<p>a</p><p>b</p>")
  assert_eq(preview("<div>a</div> <div>b</div>"), "<div>a</div><div>b</div>")
}

///|
test "whitespace next to the start or end of a node list is dropped" {
  assert_eq(preview("<p> <b>x</b></p>"), "<p><b>x</b></p>")
  assert_eq(preview("<div> text</div>"), "<div>text</div>")
  assert_eq(preview("<p>\n foo\n</p>"), "<p>foo</p>")
}

///|
test "inline elements keep the spaces around them" {
  assert_eq(
    preview(
      "<p>Inline text <b>is spaced properly</b> without adding extra spaces.</p>",
    ),
    "<p>Inline text <b>is spaced properly</b> without adding extra spaces.</p>",
  )
  assert_eq(
    preview("<span>a</span> <span>b</span>"),
    "<span>a</span> <span>b</span>",
  )
  assert_eq(preview("<p><b>a</b>\n<b>b</b></p>"), "<p><b>a</b> <b>b</b></p>")
}

///|
test "a block child drops the space on either side" {
  assert_eq(
    preview("<p><b>a</b> <div>b</div></p>"),
    "<p><b>a</b><div>b</div></p>",
  )
  assert_eq(preview("<div><p>a</p> b</div>"), "<div><p>a</p>b</div>")
  assert_eq(preview("<div>a\n<p>b</p>\nc</div>"), "<div>a<p>b</p>c</div>")
}

///|
test "whitespace within a line is kept verbatim" {
  assert_eq(preview("<p>a   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>a\tb</p>"), "<p>a\tb</p>")
  assert_eq(preview("<div>a <p>b</p></div>"), "<div>a <p>b</p></div>")
  assert_eq(preview("<div>a  <p>b</p></div>"), "<div>a  <p>b</p></div>")
  assert_eq(preview("<p>a  </p>"), "<p>a  </p>")
}

///|
test "a newline splits a whitespace run at the first line break" {
  assert_eq(preview("<p>a \n b</p>"), "<p>a  b</p>")
  assert_eq(preview("<p>a  \n  b</p>"), "<p>a   b</p>")
}

///|
test "expressions count as inline content" {
  assert_eq(preview("<p>a { x } b</p>"), "<p>a § b</p>")
  assert_eq(preview("<p>a{x}b</p>"), "<p>a§b</p>")
  assert_eq(preview("<p>{ x } a</p>"), "<p>§ a</p>")
  assert_eq(preview("<p>{ x } { y }</p>"), "<p>§ §</p>")
}

///|
test "whitespace around a lone expression is dropped" {
  assert_eq(preview("<p>{ x }</p>"), "<p>§</p>")
  assert_eq(preview("<p> { x } </p>"), "<p>§</p>")
}

///|
test "normalization recurses into nested elements" {
  assert_eq(
    preview("<div>\n <p>a</p>\n <p>b</p>\n</div>"),
    "<div><p>a</p><p>b</p></div>",
  )
  assert_eq(
    preview("<div>\n  <span>a</span>\n  <span>b</span>\n</div>"),
    "<div><span>a</span> <span>b</span></div>",
  )
}

///|
test "a whitespace-only node collapses however long it is" {
  assert_eq(
    preview("<div>\n  <span>a</span>  <span>b</span>\n</div>"),
    "<div><span>a</span> <span>b</span></div>",
  )
  assert_eq(
    preview("<span>a</span>\n\n<span>b</span>"),
    "<span>a</span> <span>b</span>",
  )
}

///|
test "whitespace inside a raw element is left exactly as written" {
  assert_eq(preview("<style>\n  a  b\n</style>"), "<style>\n  a  b\n</style>")
  assert_eq(
    preview("<div>\n  <script>var a = 1;\n  var b = 2;</script>\n</div>"),
    "<div><script>var a = 1;\n  var b = 2;</script></div>",
  )
}

///|
test "a body is indented two spaces per level" {
  let source = "templ page(title : String) {\n<div class=\"page\">\n<h1>{ title }</h1>\n<p>Hello, { name }!</p>\n</div>\n}\n"
  let expected = "templ page(title : String) {\n  <div class=\"page\">\n    <h1>{ title }</h1>\n    <p>Hello, { name }!</p>\n  </div>\n}\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "each statement takes a line of its own" {
  let source = "templ t() {\nif ok {\n<b>y</b>\n} else if maybe {\n<b>m</b>\n} else {\n<b>n</b>\n}\nfor x in xs {\n<i>{ x }</i>\n}\nmatch kind {\nSome(v) => {\n<u>{ v }</u>\n}\n_ => {\n<u>none</u>\n}\n}\n}\n"
  let expected = "templ t() {\n  if ok {\n    <b>y</b>\n  } else if maybe {\n    <b>m</b>\n  } else {\n    <b>n</b>\n  }\n  for x in xs {\n    <i>{ x }</i>\n  }\n  match kind {\n    Some(v) => {\n      <u>{ v }</u>\n    }\n    _ => {\n      <u>none</u>\n    }\n  }\n}\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "a call's block is spread out and a call in a phrase stays on its line" {
  let source = "templ t() {\n@Card(title) {\n<p>body</p>\n}\n<p>See@Link(href) { here }now</p>\n}\n"
  let expected = "templ t() {\n  @Card(title) {\n    <p>body</p>\n  }\n  <p>See@Link(href) { here }now</p>\n}\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "attributes share the line or take lines of their own" {
  let source = "templ t() {\n<a class=\"a\" data-x={ x } disabled?={ on } { extra... }>x</a>\n<div\nclass=\"a\"\nif dark {\ndata-theme=\"dark\"\n} else {\ndata-theme=\"light\"\n}\nid={ id }\n>\n<p>text</p>\n</div>\n}\n"
  let expected = "templ t() {\n  <a class=\"a\" data-x={ x } disabled?={ on } { extra... }>x</a>\n  <div\n    class=\"a\"\n    if dark {\n      data-theme=\"dark\"\n    } else {\n      data-theme=\"light\"\n    }\n    id={ id }\n  >\n    <p>text</p>\n  </div>\n}\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "a raw element keeps its contents as they stand" {
  let source = "templ t() {\n<style>\n  .a { color: red; }\n</style>\n<script>\nlet x = 1 < 2;\n</script>\n}\n"
  let expected = "templ t() {\n  <style>\n  .a { color: red; }\n</style>\n  <script>\nlet x = 1 < 2;\n</script>\n}\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "void and self-closing elements keep their spelling" {
  let source = "templ t() {\n<meta charset=\"utf-8\">\n<br>\n<hr/>\n<x-el/>\n}\n"
  let expected = "templ t() {\n  <meta charset=\"utf-8\">\n  <br>\n  <hr/>\n  <x-el/>\n}\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "a receiver is written before the name" {
  let source = "templ (self : Counter) show(n : Int) {\n  <p>{ n }</p>\n}\n"
  assert_eq(@formatter.format_source(source), source)
}

///|
/// Only the `templ` blocks are rewritten, so a file's comments and the text
/// between its blocks survive even when a block has to be realigned.
test "the text between templates is kept as it stands" {
  let source = "package demo\n\n// a note\ntempl a() {\n<p>a</p>\n}\n\ntempl b() {\n<p>b</p>\n}\n// trailing\n"
  let expected = "package demo\n\n// a note\ntempl a() {\n  <p>a</p>\n}\n\ntempl b() {\n  <p>b</p>\n}\n// trailing\n"
  assert_eq(@formatter.format_source(source), expected)
}

///|
test "a source with no templates is unchanged" {
  let source = "package demo\n\nfn main {\n  println(\"hi\")\n}\n"
  assert_eq(@formatter.format_source(source), source)
}

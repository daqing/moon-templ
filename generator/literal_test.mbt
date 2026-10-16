///|
test "plain text is only wrapped in quotes" {
  assert_eq(@generator.string_literal("hello"), "\"hello\"")
  assert_eq(@generator.string_literal(""), "\"\"")
}

///|
test "quotes and backslashes are escaped" {
  assert_eq(@generator.string_literal("a\"b"), "\"a\\\"b\"")
  assert_eq(@generator.string_literal("a\\b"), "\"a\\\\b\"")
  assert_eq(@generator.string_literal("</a>"), "\"</a>\"")
}

///|
test "whitespace uses named escapes" {
  assert_eq(@generator.string_literal("a\nb"), "\"a\\nb\"")
  assert_eq(@generator.string_literal("a\tb"), "\"a\\tb\"")
  assert_eq(@generator.string_literal("a\rb"), "\"a\\rb\"")
  assert_eq(@generator.string_literal("a\bb"), "\"a\\bb\"")
}

///|
test "other control characters use the unicode escape" {
  assert_eq(@generator.string_literal("a\u{01}b"), "\"a\\u{01}b\"")
  assert_eq(@generator.string_literal("a\u{1f}b"), "\"a\\u{1f}b\"")
}

///|
test "a template interpolation brace cannot leak into the output" {
  assert_eq(@generator.string_literal("\\{name}"), "\"\\\\{name}\"")
}

///|
test "multibyte characters are kept as they are" {
  assert_eq(@generator.string_literal("中文"), "\"中文\"")
  assert_eq(@generator.string_literal("🎉"), "\"🎉\"")
  assert_eq(@generator.string_literal("café"), "\"café\"")
}

///|
test "html entities are not escaped" {
  assert_eq(@generator.string_literal("a &amp; b"), "\"a &amp; b\"")
  assert_eq(@generator.string_literal("<p>a</p>"), "\"<p>a</p>\"")
}

///|
test "the result is already quoted" {
  let got = @generator.string_literal("x")
  assert_true(got.has_prefix("\""))
  assert_true(got.has_suffix("\""))
  assert_eq(got.length(), 3)
}

///|
/// The expectations on the right are MoonBit source text, so the compiler parses
/// them as this file builds: they only hold if the generated form really is a
/// valid literal with the same value.
test "every risky character round-trips through MoonBit source" {
  assert_eq(@generator.string_literal("\u{2028}"), "\"\u{2028}\"")
  assert_eq(@generator.string_literal("\u{7f}"), "\"\u{7f}\"")
  assert_eq(@generator.string_literal("${x}"), "\"${x}\"")
  assert_eq(@generator.string_literal("'"), "\"'\"")
  assert_eq(@generator.string_literal("\"\"\""), "\"\\\"\\\"\\\"\"")
  assert_eq(@generator.string_literal("\\n"), "\"\\\\n\"")
}

///|
/// A literal that is going to be dropped into generated source must still open
/// and close exactly once, and the body must not contain an unescaped quote.
test "the escaped form quotes itself exactly once" {
  let samples = [
    "\"", "\\", "\n", "\t", "\r", "\b", "\u{00}", "\u{01}", "\u{1f}", "\u{7f}", "\\{",
    "{", "}", "$", "`", "\u{2028}", "中文", "🎉",
  ]
  for sample in samples {
    let escaped = @generator.string_literal(sample)
    assert_true(escaped.has_prefix("\""))
    assert_true(escaped.has_suffix("\""))
    let body = escaped[:].get_view(start=1, end=escaped.length() - 1).unwrap()
    assert_true(quotes_are_escaped(body))
  }
}

///|
fn quotes_are_escaped(body : StringView) -> Bool {
  for v = body {
    match v {
      [] => break true
      ['\\', _, .. rest] => continue rest
      ['"', ..] => break false
      [_, .. rest] => continue rest
    }
  }
}

///|
test "an offset at the start of a file is line 1, column 1" {
  assert_eq(@parser.line_column("", 0), (1, 1))
  assert_eq(@parser.line_column("templ a() {}", 0), (1, 1))
}

///|
test "a column counts characters from the start of its line" {
  assert_eq(@parser.line_column("abc", 2), (1, 3))
  assert_eq(@parser.line_column("a\nbc", 3), (2, 2))
  assert_eq(@parser.line_column("a\nbc", 4), (2, 3))
}

///|
/// The offset is the start of the next line's content when it sits on a
/// newline's successor; an offset on the newline itself still belongs to the
/// line being ended, one column past its last character.
test "a newline ends a line and its successor starts at column 1" {
  assert_eq(@parser.line_column("ab\ncd", 2), (1, 3))
  assert_eq(@parser.line_column("ab\ncd", 3), (2, 1))
  assert_eq(@parser.line_column("ab\ncd", 0), (1, 1))
}

///|
/// The source is counted in the same units the parser's offsets are: a template
/// with Chinese text reports the column a reader sees, not a byte position.
test "a column counts characters, not UTF-8 bytes" {
  assert_eq(@parser.line_column("模板", 1), (1, 2))
  assert_eq(@parser.line_column("模板\nx", 3), (2, 1))
}

///|
/// An emoji outside the BMP is one character in UTF-16 code units, so every
/// column after it is not shifted by the surrogate pair.
test "a surrogate pair takes one column" {
  // "🤣" is two UTF-16 code units.
  assert_eq("🤣".length(), 2)
  assert_eq(@parser.line_column("🤣x", 2), (1, 2))
  assert_eq(@parser.line_column("🤣\nx", 3), (2, 1))
}

///|
/// A position outside the source is clamped rather than refused: a caller may
/// point at the end of the file when a construct ran out of input.
test "an offset outside the source is clamped to the source" {
  assert_eq(@parser.line_column("ab", 99), (1, 3))
  assert_eq(@parser.line_column("ab", -1), (1, 1))
  assert_eq(@parser.line_column("a\n", 99), (2, 1))
}

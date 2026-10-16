///|
/// A template literal as MoonBit source: escaped, with the quotes included.
///
/// The generated code writes this text into the HTML output verbatim, so it is
/// escaped for MoonBit's lexer only — HTML escaping is the runtime's job, and
/// would corrupt the markup if it happened here.
///
/// `String::escape()` already supplies the surrounding quotes and handles `"`,
/// `\`, and the control characters, so the result goes straight into the output
/// with no further wrapping.
pub fn string_literal(s : String) -> String {
  s.escape()
}

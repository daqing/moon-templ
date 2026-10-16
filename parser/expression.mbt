///|
/// Scan the body of a `{ ... }` expression. `src` must start just after the
/// opening `{`; `offset` is that opening brace's position, used for diagnostics.
///
/// Returns the expression source verbatim and the view positioned just after
/// the matching `}`. Braces inside string literals, rune literals and comments
/// do not close the expression.
pub fn scan_expression(
  src : StringView,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  match scan_expr(src, 0, buf) {
    Some(rest) => (buf.to_string(), rest)
    None => raise ParseError(offset~, message="unterminated expression")
  }
}

///|
fn dec(depth : Int32) -> Int32 {
  if depth > 0 {
    depth - 1
  } else {
    0
  }
}

///|
/// Whether the body of a `{ ... }` expression holds more than one value: a comma
/// that is not inside brackets, a string, a rune or a comment. templ joins those
/// values with `JoinStringErrs`; moon-templ does not support the form yet, and
/// saying so beats generating a call with the wrong number of arguments.
pub fn holds_multiple_values(expr : String) -> Bool {
  at_top_level_comma(expr[:], 0)
}

///|
fn at_top_level_comma(src : StringView, depth : Int32) -> Bool {
  match src {
    [] => false
    [',', ..] if depth == 0 => true
    ['{', .. rest] | ['(', .. rest] | ['[', .. rest] =>
      at_top_level_comma(rest, depth + 1)
    ['}', .. rest] | [')', .. rest] | [']', .. rest] =>
      at_top_level_comma(rest, dec(depth))
    ['"', .. rest] =>
      match scan_string(rest, StringBuilder()) {
        Some(r) => at_top_level_comma(r, depth)
        None => false
      }
    ['\'', .. rest] =>
      match scan_rune(rest, StringBuilder()) {
        Some(r) => at_top_level_comma(r, depth)
        None => false
      }
    ['/', '/', .. rest] =>
      match scan_line_comment(rest, StringBuilder()) {
        Some(r) => at_top_level_comma(r, depth)
        None => false
      }
    ['/', '*', .. rest] =>
      match scan_block_comment(rest, StringBuilder()) {
        Some(r) => at_top_level_comma(r, depth)
        None => false
      }
    [_, .. rest] => at_top_level_comma(rest, depth)
  }
}

///|
/// Returns `None` when the source ran out before the matching `}`.
fn scan_expr(
  src : StringView,
  depth : Int32,
  buf : StringBuilder,
) -> StringView? {
  match src {
    [] => None
    ['}', .. rest] if depth == 0 => Some(rest)
    ['}', .. rest] => {
      buf.write_char('}')
      scan_expr(rest, dec(depth), buf)
    }
    ['{', .. rest] => {
      buf.write_char('{')
      scan_expr(rest, depth + 1, buf)
    }
    ['(', .. rest] => {
      buf.write_char('(')
      scan_expr(rest, depth + 1, buf)
    }
    ['[', .. rest] => {
      buf.write_char('[')
      scan_expr(rest, depth + 1, buf)
    }
    [')', .. rest] => {
      buf.write_char(')')
      scan_expr(rest, dec(depth), buf)
    }
    [']', .. rest] => {
      buf.write_char(']')
      scan_expr(rest, dec(depth), buf)
    }
    ['"', .. rest] => {
      buf.write_char('"')
      match scan_string(rest, buf) {
        None => None
        Some(r) => scan_expr(r, depth, buf)
      }
    }
    ['\'', .. rest] => {
      buf.write_char('\'')
      match scan_rune(rest, buf) {
        None => None
        Some(r) => scan_expr(r, depth, buf)
      }
    }
    ['/', '/', .. rest] => {
      buf.write_string("//")
      match scan_line_comment(rest, buf) {
        None => None
        Some(r) => scan_expr(r, depth, buf)
      }
    }
    ['/', '*', .. rest] => {
      buf.write_string("/*")
      match scan_block_comment(rest, buf) {
        None => None
        Some(r) => scan_expr(r, depth, buf)
      }
    }
    [c, .. rest] => {
      buf.write_char(c)
      scan_expr(rest, depth, buf)
    }
  }
}

///|
fn scan_string(src : StringView, buf : StringBuilder) -> StringView? {
  match src {
    [] => None
    ['\\', c, .. rest] => {
      buf.write_char('\\')
      buf.write_char(c)
      scan_string(rest, buf)
    }
    ['"', .. rest] => {
      buf.write_char('"')
      Some(rest)
    }
    [c, .. rest] => {
      buf.write_char(c)
      scan_string(rest, buf)
    }
  }
}

///|
fn scan_rune(src : StringView, buf : StringBuilder) -> StringView? {
  match src {
    [] => None
    ['\\', c, .. rest] => {
      buf.write_char('\\')
      buf.write_char(c)
      scan_rune(rest, buf)
    }
    ['\'', .. rest] => {
      buf.write_char('\'')
      Some(rest)
    }
    [c, .. rest] => {
      buf.write_char(c)
      scan_rune(rest, buf)
    }
  }
}

///|
/// A line comment runs to the end of the line. At EOF the view is simply
/// exhausted, which makes the enclosing expression unterminated.
fn scan_line_comment(src : StringView, buf : StringBuilder) -> StringView? {
  match src {
    [] => Some(src)
    ['\n', .. rest] => {
      buf.write_char('\n')
      Some(rest)
    }
    [c, .. rest] => {
      buf.write_char(c)
      scan_line_comment(rest, buf)
    }
  }
}

///|
fn scan_block_comment(src : StringView, buf : StringBuilder) -> StringView? {
  match src {
    [] => None
    ['*', '/', .. rest] => {
      buf.write_string("*/")
      Some(rest)
    }
    [c, .. rest] => {
      buf.write_char(c)
      scan_block_comment(rest, buf)
    }
  }
}

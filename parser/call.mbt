///|
/// Parse a `@expr` or `@expr { ... }` component call. `src` starts at the `@`
/// marker, which this consumes.
///
/// What follows is a MoonBit expression. A reference to another package is
/// spelled the way MoonBit spells it, so a call to `ui`'s `card` is written
/// `@ui.card(title)`: the same `@` marks the call and stands for the package
/// reference.
pub fn parse_call(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_marker = match src {
    ['@', .. rest] => rest
    _ => raise ParseError(offset~, message="expected '@'")
  }
  let (expression, after_expression) = scan_call_expression(
    after_marker, offset,
  )
  let (children, rest) = parse_call_children(
    after_expression, expression, offset,
  )
  (Call({ expression, children, }), rest)
}

///|
/// A call's children block opens with a `{` that may be padded with spaces or
/// tabs — never with a newline, which would put the brace on a line of its own
/// and make it an ordinary expression instead, as it does in templ. `src` is
/// returned untouched when there is no block.
fn parse_call_children(
  src : StringView,
  expression : String,
  offset : Int32,
) -> (Array[Node], StringView) raise ParseError {
  let body = match take_spaces(src) {
    ['{', .. rest] => take_spaces(rest)
    _ => return ([], src)
  }
  let body_at = offset + consumed(src, body)
  let (nodes, at_close) = parse_nodes(body, body_at, fn(v) {
    v.has_prefix("}"[:])
  })
  match at_close {
    [] =>
      raise ParseError(
        offset~,
        message="@" + expression + ": missing end (expected '}')",
      )
    _ => (normalize_block_whitespace(nodes), drop_prefix(at_close, "}"[:]))
  }
}

///|
fn take_spaces(src : StringView) -> StringView {
  match src {
    [' ', .. rest] | ['\t', .. rest] => take_spaces(rest)
    _ => src
  }
}

///|
/// Scan the expression a call renders. It is a name, optionally qualified and
/// optionally followed by calls, indexings and field selections — `Card`,
/// `@ui.Card(title)`, `cards[i].render` — and it ends at the first character
/// that cannot continue it. Whitespace ends it too, so `@f(a) .g` is a call to
/// `f(a)` followed by the text ` .g`.
fn scan_call_expression(
  src : StringView,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  if is_package_reference(src) {
    buf.write_char('@')
  }
  let after_name = take_call_name(src, offset, buf)
  let rest = scan_call_suffixes(after_name, offset, buf)
  (buf.to_string(), rest)
}

///|
/// Whether the expression names a component in another package: `ui.card` has
/// a package name ahead of a `.`, so the `@` that marks the call is also the
/// reference's own.
fn is_package_reference(src : StringView) -> Bool {
  match src {
    [c, .. rest] if is_ident_start(c) => ident_ends_before_dot(rest)
    _ => false
  }
}

///|
fn ident_ends_before_dot(src : StringView) -> Bool {
  match src {
    ['.', ..] => true
    [c, .. rest] if is_ident_char(c) => ident_ends_before_dot(rest)
    _ => false
  }
}

///|
fn take_call_name(
  src : StringView,
  offset : Int32,
  buf : StringBuilder,
) -> StringView raise ParseError {
  match src {
    [c, ..] if is_ident_start(c) => take_ident(src, buf)
    _ =>
      raise ParseError(offset~, message="expected a component name after '@'")
  }
}

///|
fn is_ident_start(c : Char) -> Bool {
  is_lower(c) || (c >= 'A' && c <= 'Z') || c == '_'
}

///|
/// Everything that may follow a call's name: `.field`, `::method`, `(args)` and
/// `[index]`, in any order and any number.
fn scan_call_suffixes(
  src : StringView,
  offset : Int32,
  buf : StringBuilder,
) -> StringView raise ParseError {
  match src {
    ['.', .. rest] => {
      buf.write_char('.')
      let after = take_call_name(rest, offset, buf)
      scan_call_suffixes(after, offset, buf)
    }
    [':', ':', .. rest] => {
      buf.write_string("::")
      let after = take_call_name(rest, offset, buf)
      scan_call_suffixes(after, offset, buf)
    }
    ['(', .. rest] => {
      buf.write_char('(')
      let after = take_balanced(rest, ')', offset, buf)
      scan_call_suffixes(after, offset, buf)
    }
    ['[', .. rest] => {
      buf.write_char('[')
      let after = take_balanced(rest, ']', offset, buf)
      scan_call_suffixes(after, offset, buf)
    }
    _ => src
  }
}

///|
/// Consume everything up to the `close` matching the opening bracket already
/// written to `buf`, writing that closing character too. Brackets nest, and a
/// `close` inside a string, a rune or a comment does not end the scan.
fn take_balanced(
  src : StringView,
  close : Char,
  offset : Int32,
  buf : StringBuilder,
) -> StringView raise ParseError {
  match src {
    [] =>
      raise ParseError(
        offset~,
        message="expected '\{close}' to close a component call",
      )
    [c, .. rest] if c == close => {
      buf.write_char(c)
      rest
    }
    ['(', .. rest] => {
      buf.write_char('(')
      let after = take_balanced(rest, ')', offset, buf)
      take_balanced(after, close, offset, buf)
    }
    ['[', .. rest] => {
      buf.write_char('[')
      let after = take_balanced(rest, ']', offset, buf)
      take_balanced(after, close, offset, buf)
    }
    ['{', .. rest] => {
      buf.write_char('{')
      let after = take_balanced(rest, '}', offset, buf)
      take_balanced(after, close, offset, buf)
    }
    ['"', .. rest] => {
      buf.write_char('"')
      match scan_string(rest, buf) {
        None => raise ParseError(offset~, message="unterminated string")
        Some(after) => take_balanced(after, close, offset, buf)
      }
    }
    ['\'', .. rest] => {
      buf.write_char('\'')
      match scan_rune(rest, buf) {
        None => raise ParseError(offset~, message="unterminated rune")
        Some(after) => take_balanced(after, close, offset, buf)
      }
    }
    ['/', '/', .. rest] => {
      buf.write_string("//")
      match scan_line_comment(rest, buf) {
        None => raise ParseError(offset~, message="unterminated comment")
        Some(after) => take_balanced(after, close, offset, buf)
      }
    }
    ['/', '*', .. rest] => {
      buf.write_string("/*")
      match scan_block_comment(rest, buf) {
        None => raise ParseError(offset~, message="unterminated comment")
        Some(after) => take_balanced(after, close, offset, buf)
      }
    }
    [c, .. rest] => {
      buf.write_char(c)
      take_balanced(rest, close, offset, buf)
    }
  }
}

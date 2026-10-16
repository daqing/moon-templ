///|
fn is_attr_name_first(c : Char) -> Bool {
  is_lower(c) || (c >= 'A' && c <= 'Z') || c == ':' || c == '_' || c == '@'
}

///|
fn is_attr_name_char(c : Char) -> Bool {
  is_attr_name_first(c) || is_digit(c) || c == '-' || c == '.' || c == '*'
}

///|
fn is_space(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '\r' || c == '\n'
}

///|
/// Per the HTML spec an unquoted attribute value ends at whitespace or at any of
/// `` "'`=<>/ `.
fn ends_unquoted(c : Char) -> Bool {
  is_space(c) ||
  c == '"' ||
  c == '\'' ||
  c == '`' ||
  c == '=' ||
  c == '<' ||
  c == '>' ||
  c == '/'
}

///|
fn skip_space(src : StringView) -> StringView {
  match src {
    [c, .. rest] if is_space(c) => skip_space(rest)
    _ => src
  }
}

///|
/// Parse the attribute list of a start tag. Returns the attributes, the view just
/// past the closing `>` and whether the tag was self-closing.
pub fn parse_attributes(
  src : StringView,
  offset : Int32,
) -> (Array[Attribute], StringView, Bool) raise ParseError {
  let out : Array[Attribute] = []
  let (rest, self_closing) = parse_attributes_into(src, offset, out)
  (out, rest, self_closing)
}

///|
fn parse_attributes_into(
  src : StringView,
  offset : Int32,
  out : Array[Attribute],
) -> (StringView, Bool) raise ParseError {
  let at = skip_space(src)
  match at {
    [] => raise ParseError(offset~, message="unterminated start tag")
    ['/', '>', .. rest] => (rest, true)
    ['>', .. rest] => (rest, false)
    _ => {
      let (attr, rest) = parse_attribute(at, offset)
      out.push(attr)
      parse_attributes_into(rest, offset, out)
    }
  }
}

///|
fn parse_attribute(
  src : StringView,
  offset : Int32,
) -> (Attribute, StringView) raise ParseError {
  let name_buf = StringBuilder()
  let after_name = match src {
    [c, ..] if is_attr_name_first(c) => take_attribute_name(src, name_buf)
    [c, ..] =>
      raise ParseError(offset~, message="expected attribute name, found '\{c}'")
    _ => raise ParseError(offset~, message="expected attribute name")
  }
  let name = name_buf.to_string()
  if name.length() > 128 {
    raise ParseError(
      offset~,
      message="attribute names must be at most 128 characters",
    )
  }
  match after_name {
    ['=', .. rest] => {
      let (attr, after) = parse_attribute_value(rest, name, offset)
      (attr, after)
    }
    ['?', ..] =>
      raise ParseError(
        offset~,
        message="boolean expression attributes are not supported yet: " +
          name +
          "?={ ... }",
      )
    _ => (Bool(name~), after_name)
  }
}

///|
/// The value of a `name=...` attribute, whatever form it takes. An expression is
/// not a value in the AST sense, so the quoted and unquoted forms build a
/// `Constant` here and the expression form builds an `Expression`, which is how
/// the generator tells code from text.
fn parse_attribute_value(
  src : StringView,
  name : String,
  offset : Int32,
) -> (Attribute, StringView) raise ParseError {
  match src {
    ['"', .. rest] => {
      let (value, after) = scan_quoted(rest, '"', offset)
      (Constant(name~, value~), after)
    }
    ['\'', .. rest] => {
      let (value, after) = scan_quoted(rest, '\'', offset)
      (Constant(name~, value~), after)
    }
    ['{', .. rest] => {
      let (value, after) = scan_expression(rest, offset)
      (Expression(name~, value~), after)
    }
    _ => {
      let buf = StringBuilder()
      let rest = take_unquoted(src, buf)
      let value = buf.to_string()
      if value.is_empty() {
        raise ParseError(offset~, message="expected attribute value")
      }
      (Constant(name~, value~), rest)
    }
  }
}

///|
fn take_attribute_name(src : StringView, buf : StringBuilder) -> StringView {
  match src {
    [c, .. rest] if is_attr_name_char(c) => {
      buf.write_char(c)
      take_attribute_name(rest, buf)
    }
    _ => src
  }
}

///|
fn take_unquoted(src : StringView, buf : StringBuilder) -> StringView {
  match src {
    [c, .. rest] if !ends_unquoted(c) => {
      buf.write_char(c)
      take_unquoted(rest, buf)
    }
    _ => src
  }
}

///|
fn scan_quoted(
  src : StringView,
  quote : Char,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  scan_quoted_into(src, quote, offset, buf)
}

///|
fn scan_quoted_into(
  src : StringView,
  quote : Char,
  offset : Int32,
  buf : StringBuilder,
) -> (String, StringView) raise ParseError {
  match src {
    [] => raise ParseError(offset~, message="unterminated quoted value")
    [c, .. rest] if c == quote => (buf.to_string(), rest)
    [c, .. rest] => {
      buf.write_char(c)
      scan_quoted_into(rest, quote, offset, buf)
    }
  }
}

///|
fn is_lower(c : Char) -> Bool {
  c >= 'a' && c <= 'z'
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// Element names start with a lowercase letter; templ rejects uppercase so that
/// component calls and HTML tags stay distinguishable.
fn is_name_start(c : Char) -> Bool {
  is_lower(c)
}

///|
fn is_name_char(c : Char) -> Bool {
  is_lower(c) || is_digit(c) || c == '-' || c == ':'
}

///|
/// HTML void elements have no closing tag and no children.
fn is_void_element(name : String) -> Bool {
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
fn consumed(before : StringView, after : StringView) -> Int32 {
  before.length() - after.length()
}

///|
/// Parse nodes until `stop` matches the current position, or the source runs out.
/// The returned view starts at whatever `stop` matched.
pub fn parse_nodes(
  src : StringView,
  offset : Int32,
  stop : (StringView) -> Bool,
) -> (Array[Node], StringView) raise ParseError {
  let out : Array[Node] = []
  let rest = parse_nodes_into(src, offset, stop, out)
  (out, rest)
}

///|
fn parse_nodes_into(
  src : StringView,
  offset : Int32,
  stop : (StringView) -> Bool,
  out : Array[Node],
) -> StringView raise ParseError {
  if stop(src) {
    return src
  }
  match src {
    [] => src
    ['<', ..] => {
      let (node, rest) = parse_element(src, offset)
      out.push(node)
      parse_nodes_into(rest, offset + consumed(src, rest), stop, out)
    }
    ['{', .. rest] => {
      let (expr, after) = scan_expression(rest, offset)
      out.push(StringExpression(expr))
      parse_nodes_into(after, offset + consumed(src, after), stop, out)
    }
    _ => {
      let buf = StringBuilder()
      let rest = take_text(src, buf)
      out.push(Text(buf.to_string()))
      parse_nodes_into(rest, offset + consumed(src, rest), stop, out)
    }
  }
}

///|
/// Text runs until the next tag or expression; those are separate nodes.
fn take_text(src : StringView, buf : StringBuilder) -> StringView {
  match src {
    [] => src
    ['<', ..] => src
    ['{', ..] => src
    [c, .. rest] => {
      buf.write_char(c)
      take_text(rest, buf)
    }
  }
}

///|
fn take_name(src : StringView, buf : StringBuilder) -> StringView {
  match src {
    [c, .. rest] if is_name_char(c) => {
      buf.write_char(c)
      take_name(rest, buf)
    }
    _ => src
  }
}

///|
fn parse_element(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_lt = match src {
    ['<', .. rest] => rest
    _ => raise ParseError(offset~, message="expected '<'")
  }
  let name_buf = StringBuilder()
  let after_name = match after_lt {
    [c, ..] if is_name_start(c) => take_name(after_lt, name_buf)
    [c, ..] =>
      raise ParseError(
        offset~,
        message="element name must start with a lowercase letter: \{c}",
      )
    _ => raise ParseError(offset~, message="expected element name")
  }
  let name = name_buf.to_string()
  let (after_attrs, self_closing) = skip_attrs(after_name, offset)
  if self_closing || is_void_element(name) {
    return (
      Element({ name, attrs: [], children: [], self_closing, }),
      after_attrs,
    )
  }
  let close = "</" + name + ">"
  let (children, at_close) = parse_nodes(
    after_attrs,
    offset + consumed(src, after_attrs),
    fn(v) { v.has_prefix(close[:]) },
  )
  let rest = match at_close {
    [] => raise ParseError(offset~, message="unclosed element <" + name + ">")
    _ => drop_prefix(at_close, close[:])
  }
  (Element({ name, attrs: [], children, self_closing: false, }), rest)
}

///|
fn drop_prefix(view : StringView, prefix : StringView) -> StringView {
  match view.get_view(start=prefix.length()) {
    Some(rest) => rest
    None => ""[:]
  }
}

///|
/// Skip the attribute list to the end of the start tag. Values are skipped
/// without being interpreted; quoting is honoured so `>` inside a value does
/// not end the tag.
fn skip_attrs(
  src : StringView,
  offset : Int32,
) -> (StringView, Bool) raise ParseError {
  match src {
    [] => raise ParseError(offset~, message="unterminated start tag")
    ['/', '>', .. rest] => (rest, true)
    ['>', .. rest] => (rest, false)
    ['"', .. rest] => {
      let (_, after) = scan_quoted(rest, '"', offset)
      skip_attrs(after, offset)
    }
    ['\'', .. rest] => {
      let (_, after) = scan_quoted(rest, '\'', offset)
      skip_attrs(after, offset)
    }
    [_, .. rest] => skip_attrs(rest, offset)
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

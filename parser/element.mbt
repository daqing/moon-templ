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
pub fn is_void_element(name : String) -> Bool {
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
      let (node, rest) = parse_tag(src, offset)
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
      let rest = take_text(src, buf, stop)
      out.push(Text(buf.to_string()))
      parse_nodes_into(rest, offset + consumed(src, rest), stop, out)
    }
  }
}

///|
/// Anything starting with `<`: a comment or a doctype, a raw text element, or an
/// ordinary element — in that order. The first two are recognised here rather
/// than in `parse_element`, which would reject the `!` they open with.
fn parse_tag(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  if src.has_prefix("<!--"[:]) {
    return parse_html_comment(src, offset)
  }
  match doctype_open_length(src) {
    Some(length) => parse_doctype(src, length, offset)
    None =>
      match raw_element_name(src) {
        Some(name) => parse_raw_element(src, name, offset)
        None => parse_element(src, offset)
      }
  }
}

///|
/// Text runs until the next tag or expression; those are separate nodes. It also
/// stops where `stop` matches, which is how the `}` closing a template body ends
/// the final text node.
fn take_text(
  src : StringView,
  buf : StringBuilder,
  stop : (StringView) -> Bool,
) -> StringView {
  if stop(src) {
    return src
  }
  match src {
    [] => src
    ['<', ..] => src
    ['{', ..] => src
    [c, .. rest] => {
      buf.write_char(c)
      take_text(rest, buf, stop)
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
  let (attrs, after_attrs, self_closing) = parse_attributes(after_name, offset)
  if self_closing || is_void_element(name) {
    return (Element({ name, attrs, children: [], self_closing, }), after_attrs)
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
  (Element({ name, attrs, children, self_closing: false, }), rest)
}

///|
fn drop_prefix(view : StringView, prefix : StringView) -> StringView {
  match view.get_view(start=prefix.length()) {
    Some(rest) => rest
    None => ""[:]
  }
}

///|
/// The name of a raw text element at this position, if any. Deciding it here,
/// ahead of the general element parser, is what stops the contents of `<style>`
/// and `<script>` from being read as template syntax.
fn raw_element_name(view : StringView) -> String? {
  let after_lt = match view {
    ['<', .. rest] => rest
    _ => return None
  }
  for name in ["style", "script"] {
    if after_lt.has_prefix(name[:]) {
      match drop_prefix(after_lt, name[:]) {
        []
        | [' ', ..]
        | ['\t', ..]
        | ['\r', ..]
        | ['\n', ..]
        | ['>', ..]
        | ['/', ..] => return Some(name)
        _ => ()
      }
    }
  }
  None
}

///|
/// Parse a raw text element: the open tag as usual, then everything up to the
/// closing tag as it stands.
fn parse_raw_element(
  src : StringView,
  name : String,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_name = match src {
    ['<', .. rest] => drop_prefix(rest, name[:])
    _ => raise ParseError(offset~, message="expected '<'")
  }
  let (attrs, after_open, self_closing) = parse_attributes(after_name, offset)
  // `<style/>` is not a raw element at all; it closes itself on the spot.
  if self_closing {
    return (
      Element({ name, attrs, children: [], self_closing: true, }),
      after_open,
    )
  }
  let close = "</" + name + ">"
  let buf = StringBuilder()
  match take_until(after_open, close[:], buf) {
    Some(rest) =>
      (RawElement({ name, attrs, contents: buf.to_string(), }), rest)
    None =>
      raise ParseError(
        offset~,
        message="<" + name + ">: expected end tag not present",
      )
  }
}

///|
/// Everything up to the next `close`, which is consumed. `None` when the source
/// runs out first.
fn take_until(
  src : StringView,
  close : StringView,
  buf : StringBuilder,
) -> StringView? {
  if src.has_prefix(close) {
    return Some(drop_prefix(src, close))
  }
  match src {
    [] => None
    [c, .. rest] => {
      buf.write_char(c)
      take_until(rest, close, buf)
    }
  }
}

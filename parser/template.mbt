///|
/// Parse a `.templ` file into its `templ` blocks.
///
/// Everything that is not part of a `templ` block is skipped: a `.templ` file
/// holds templates and comments, while imports and helper code live in ordinary
/// `.mbt` files.
pub fn parse_template_file(src : String) -> TemplateFile raise ParseError {
  let templates : Array[Template] = []
  parse_file(src[:], 0, templates)
  { templates, }
}

///|
fn parse_file(
  src : StringView,
  offset : Int32,
  out : Array[Template],
) -> Unit raise ParseError {
  let view = skip_space(src)
  let at = offset + consumed(src, view)
  match view {
    [] => ()
    _ =>
      if is_template_start(view) {
        let (template, rest) = parse_template(view, at)
        out.push(template)
        parse_file(rest, at + consumed(view, rest), out)
      } else {
        let rest = skip_line(view)
        parse_file(rest, at + consumed(view, rest), out)
      }
  }
}

///|
/// The keyword needs trailing whitespace so that identifiers such as `template`
/// are read as plain text rather than as a malformed declaration.
fn is_template_start(view : StringView) -> Bool {
  if !view.has_prefix("templ"[:]) {
    return false
  }
  match drop_prefix(view, "templ"[:]) {
    [' ', ..] | ['\t', ..] => true
    _ => false
  }
}

///|
fn skip_line(src : StringView) -> StringView {
  match src {
    [] => src
    ['\n', .. rest] => rest
    [_, .. rest] => skip_line(rest)
  }
}

///|
fn parse_template(
  view : StringView,
  offset : Int32,
) -> (Template, StringView) raise ParseError {
  let after_keyword = drop_prefix(view, "templ"[:])
  let keyword_at = offset + consumed(view, after_keyword)
  let (signature, at_brace) = scan_signature(after_keyword, keyword_at)
  let (name, receiver, params) = split_signature(signature, keyword_at)
  let body = match at_brace {
    ['{', .. rest] => rest
    _ =>
      raise ParseError(
        offset~,
        message="expected '{' after the template signature",
      )
  }
  let body_at = offset + consumed(view, body)
  let (nodes, at_close) = parse_nodes(body, body_at, fn(v) {
    v.has_prefix("}"[:])
  })
  let rest = match at_close {
    [] =>
      raise ParseError(
        offset~,
        message="unclosed templ block: expected '}' to close " + name,
      )
    _ => drop_prefix(at_close, "}"[:])
  }
  (
    {
      name,
      receiver,
      params,
      nodes: normalize_whitespace(nodes),
      start: offset,
      end: offset + consumed(view, rest),
    },
    rest,
  )
}

///|
/// Scan to the `{` that opens the template body and return the declaration text
/// verbatim, exactly as templ does: everything up to that brace is copied
/// through rather than parsed into a parameter structure.
fn scan_signature(
  src : StringView,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  match scan_signature_into(src, 0, 0, 0, buf) {
    Some(rest) => (buf.to_string(), rest)
    None =>
      raise ParseError(
        offset~,
        message="unterminated template declaration: expected '{'",
      )
  }
}

///|
/// Returns the view of the body's opening brace, or `None` at end of input.
fn scan_signature_into(
  src : StringView,
  paren : Int32,
  bracket : Int32,
  brace : Int32,
  buf : StringBuilder,
) -> StringView? {
  match src {
    [] => None
    ['{', .. rest] =>
      if paren == 0 && bracket == 0 && brace == 0 {
        Some(src)
      } else {
        buf.write_char('{')
        scan_signature_into(rest, paren, bracket, brace + 1, buf)
      }
    ['}', .. rest] => {
      buf.write_char('}')
      scan_signature_into(rest, paren, bracket, dec(brace), buf)
    }
    ['(', .. rest] => {
      buf.write_char('(')
      scan_signature_into(rest, paren + 1, bracket, brace, buf)
    }
    [')', .. rest] => {
      buf.write_char(')')
      scan_signature_into(rest, dec(paren), bracket, brace, buf)
    }
    ['[', .. rest] => {
      buf.write_char('[')
      scan_signature_into(rest, paren, bracket + 1, brace, buf)
    }
    [']', .. rest] => {
      buf.write_char(']')
      scan_signature_into(rest, paren, dec(bracket), brace, buf)
    }
    ['"', .. rest] => {
      buf.write_char('"')
      match scan_string(rest, buf) {
        None => None
        Some(r) => scan_signature_into(r, paren, bracket, brace, buf)
      }
    }
    ['\'', .. rest] => {
      buf.write_char('\'')
      match scan_rune(rest, buf) {
        None => None
        Some(r) => scan_signature_into(r, paren, bracket, brace, buf)
      }
    }
    ['/', '/', .. rest] => {
      buf.write_string("//")
      match scan_line_comment(rest, buf) {
        None => None
        Some(r) => scan_signature_into(r, paren, bracket, brace, buf)
      }
    }
    ['/', '*', .. rest] => {
      buf.write_string("/*")
      match scan_block_comment(rest, buf) {
        None => None
        Some(r) => scan_signature_into(r, paren, bracket, brace, buf)
      }
    }
    [c, .. rest] => {
      buf.write_char(c)
      scan_signature_into(rest, paren, bracket, brace, buf)
    }
  }
}

///|
/// Split `(self : Model) Greeting(name : String)` into its name, receiver and
/// parameter list. The receiver and the parameters keep their source spelling
/// without the enclosing parentheses.
fn split_signature(
  signature : String,
  offset : Int32,
) -> (String, String, String) raise ParseError {
  let view = skip_space(signature[:])
  let (receiver, after_receiver) = match view {
    ['(', ..] => {
      let (inner, rest) = take_group(view, '(', ')', offset)
      (trim_space(inner), rest)
    }
    _ => ("", view)
  }
  let name_buf = StringBuilder()
  let after_name = take_ident(skip_space(after_receiver), name_buf)
  let name = name_buf.to_string()
  if name.is_empty() {
    raise ParseError(offset~, message="expected a template name after `templ`")
  }
  let params_view = skip_space(after_name)
  let (params, after_params) = match params_view {
    ['(', ..] => {
      let (inner, rest) = take_group(params_view, '(', ')', offset)
      (trim_space(inner), rest)
    }
    _ =>
      raise ParseError(
        offset~,
        message="expected a parameter list after the template name " + name,
      )
  }
  let trailing = skip_space(after_params)
  if !trailing.is_empty() {
    raise ParseError(
      offset~,
      message="unexpected text after the template signature: " +
        trim_space(trailing.to_owned()),
    )
  }
  (name, receiver, params)
}

///|
fn take_ident(src : StringView, buf : StringBuilder) -> StringView {
  match src {
    [c, .. rest] if is_ident_char(c) => {
      buf.write_char(c)
      take_ident(rest, buf)
    }
    _ => src
  }
}

///|
fn is_ident_char(c : Char) -> Bool {
  is_lower(c) || (c >= 'A' && c <= 'Z') || is_digit(c) || c == '_'
}

///|
/// Consume a balanced `( ... )` or `[ ... ]` group and return its contents.
fn take_group(
  src : StringView,
  open : Char,
  close : Char,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  match src {
    [c, .. rest] if c == open => {
      let buf = StringBuilder()
      let after = take_group_into(rest, open, close, offset, 1, buf)
      (buf.to_string(), after)
    }
    _ => raise ParseError(offset~, message="expected '\{open}'")
  }
}

///|
fn take_group_into(
  src : StringView,
  open : Char,
  close : Char,
  offset : Int32,
  depth : Int32,
  buf : StringBuilder,
) -> StringView raise ParseError {
  match src {
    [] =>
      raise ParseError(
        offset~,
        message="unbalanced '\{open}' in the template signature",
      )
    [c, .. rest] if c == open => {
      buf.write_char(c)
      take_group_into(rest, open, close, offset, depth + 1, buf)
    }
    [c, .. rest] if c == close =>
      if depth == 1 {
        rest
      } else {
        buf.write_char(c)
        take_group_into(rest, open, close, offset, depth - 1, buf)
      }
    [c, .. rest] => {
      buf.write_char(c)
      take_group_into(rest, open, close, offset, depth, buf)
    }
  }
}

///|
fn trim_space(s : String) -> String {
  let chars = s.to_array()
  let len = chars.length()
  let mut start = 0
  let mut end = len
  while start < end && is_space(chars[start]) {
    start = start + 1
  }
  while end > start && is_space(chars[end - 1]) {
    end = end - 1
  }
  build(chars, start, end)
}

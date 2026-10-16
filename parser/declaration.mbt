///|
/// `<!-- ... -->`. As in templ, the contents are what sits between the
/// delimiters; the generator puts `<!--` and `-->` back when it writes the node.
fn parse_html_comment(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_open = drop_prefix(src, "<!--"[:])
  let buf = StringBuilder()
  match take_until(after_open, "--"[:], buf) {
    None =>
      raise ParseError(
        offset~,
        message="expected end comment literal '-->' not found",
      )
    Some(rest) =>
      match rest {
        ['>', .. after] => (HTMLComment(buf.to_string()), after)
        _ =>
          raise ParseError(
            offset~,
            message="comment contains invalid sequence '--'",
          )
      }
  }
}

///|
/// The length of a leading `<!doctype `, matched without regard to case as templ
/// matches it, so `<!DOCTYPE html>` is one too. `None` when this is not a
/// doctype.
fn doctype_open_length(src : StringView) -> Int32? {
  let marker = "<!doctype "
  match src.get_view(end=marker.length()) {
    Some(head) =>
      if head.to_lower() == marker[:] {
        Some(marker.length())
      } else {
        None
      }
    None => None
  }
}

///|
/// `<!doctype html>`: whatever sits between the keyword and `>` is the doctype's
/// value, and it is kept. Normalising it away would silently turn a doctype this
/// generator has no business rewriting into the HTML5 one.
fn parse_doctype(
  src : StringView,
  open_length : Int32,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_open = match src.get_view(start=open_length) {
    Some(rest) => rest
    None => raise ParseError(offset~, message="unclosed DOCTYPE")
  }
  let buf = StringBuilder()
  match take_until_angle(after_open, buf) {
    ['>', .. rest] => (DocType(buf.to_string()), rest)
    _ => raise ParseError(offset~, message="unclosed DOCTYPE")
  }
}

///|
/// Everything up to the next `<` or `>`, which is not consumed: a doctype's value
/// can hold neither.
fn take_until_angle(src : StringView, buf : StringBuilder) -> StringView {
  match src {
    [] | ['<', ..] | ['>', ..] => src
    [c, .. rest] => {
      buf.write_char(c)
      take_until_angle(rest, buf)
    }
  }
}

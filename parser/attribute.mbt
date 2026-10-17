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
  match src {
    ['{', .. rest] => parse_spread_attribute(rest, offset)
    _ =>
      // `if ` is what tells a conditional attribute from one called `if`, as it
      // does in templ: `if="x"` is an attribute of that name.
      if src.has_prefix("if "[:]) {
        parse_conditional_attribute(src, offset)
      } else {
        parse_named_attribute(src, offset)
      }
  }
}

///|
/// `if expr { attrs } else { attrs }`: the attributes a tag carries, decided at
/// render time. Nothing about the branch is text of the tag, so what is between
/// the braces is a list of attributes and nothing else.
fn parse_conditional_attribute(
  src : StringView,
  offset : Int32,
) -> (Attribute, StringView) raise ParseError {
  let after_if = drop_prefix(src, "if "[:])
  let (condition, after_open) = open_attribute_block(after_if, offset)
  let then_attrs : Array[Attribute] = []
  let at_close = parse_branch_attributes(after_open, offset, then_attrs, "if")
  if then_attrs.is_empty() {
    raise ParseError(
      offset~,
      message="if: expected attributes in the block, but none were found",
    )
  }
  let (else_attrs, at_close) = match take_attribute_else(at_close, offset) {
    Some(pair) => pair
    None => ([], at_close)
  }
  (
    Conditional(condition~, then=then_attrs, else_=else_attrs),
    close_brace(at_close, offset, keyword="if"),
  )
}

///|
/// The head of an attribute branch — `if <condition>` and the `{` that opens it,
/// with the view inside the block.
///
/// templ reads this head with its Go parser, which wants the brace on the line the
/// condition is on: `if p` with a `{` below it is "unexpected newline, expecting {
/// after if clause" there, which is why `open_block` is not the one used here. The
/// other way round is fine — the newline *after* the brace is optional, since what
/// follows is an attribute list rather than a node list, so a whole branch may sit
/// on one line.
fn open_attribute_block(
  src : StringView,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  let at_brace = match scan_head(src, 0, buf, at_open_brace) {
    Some(rest) => rest
    None =>
      raise ParseError(offset~, message="if: missing '{' after the condition")
  }
  // The newline is looked for before the text is trimmed, since the one templ
  // rejects is the one that put the brace on the next line.
  let head = buf.to_string()
  if head.contains("\n") {
    raise ParseError(
      offset~,
      message="if: expected '{' on the line the condition is on",
    )
  }
  let condition = trim_space(head)
  if condition.is_empty() {
    raise ParseError(offset~, message="if: expected a condition before '{'")
  }
  match take_spaces(at_brace) {
    ['{', .. rest] => (condition, skip_space(rest))
    _ =>
      raise ParseError(offset~, message="if: expected '{' after the condition")
  }
}

///|
/// Read attributes up to the `}` that closes the branch, which is left where it
/// stands: whether it opens an `else` is the caller's to decide.
fn parse_branch_attributes(
  src : StringView,
  offset : Int32,
  out : Array[Attribute],
  keyword : String,
) -> StringView raise ParseError {
  let at = skip_space(src)
  match at {
    // The `>` of the tag is where the list would have ended had the branch been
    // closed, so a block that reaches one never had its `}`.
    [] | ['>', ..] | ['/', '>', ..] =>
      raise ParseError(
        offset~,
        message=keyword + ": missing '}' to close the block",
      )
    ['}', ..] => at
    _ => {
      let (attr, rest) = parse_attribute(at, offset)
      out.push(attr)
      parse_branch_attributes(rest, offset, out, keyword)
    }
  }
}

///|
/// The `} else { attrs }` of a conditional attribute, if that is what stands here.
/// The opening `}` of the else is the one that closed the `if` branch, so a `}`
/// that is followed by anything else means the block has no else at all.
///
/// `else if` is not a form an attribute block has, and templ reads one as an
/// `else` attribute followed by a second `if` — `<div if p { class="a" } else if q
/// { class="b" }>` renders `<div class="a" else>` for a true `p`. Refusing it says
/// what to write instead of rendering that.
fn take_attribute_else(
  src : StringView,
  offset : Int32,
) -> (Array[Attribute], StringView)? raise ParseError {
  match src {
    ['}', .. after_brace] =>
      match skip_space(after_brace) {
        ['e', 'l', 's', 'e', .. after_else] =>
          match skip_space(after_else) {
            ['{', .. body] => {
              let attrs : Array[Attribute] = []
              let at_close = parse_branch_attributes(
                body, offset, attrs, "else",
              )
              if attrs.is_empty() {
                raise ParseError(
                  offset~,
                  message="else: expected attributes in the block, but none were found",
                )
              }
              Some((attrs, at_close))
            }
            _ =>
              raise ParseError(
                offset~,
                message="else: expected '{' after it, since an attribute block has no `else if`",
              )
          }
        _ => None
      }
    _ => None
  }
}

///|
/// `{ attrs... }`: the rest of the element's attributes come from a value the
/// template computes. The braces are not part of the expression, so a spread is
/// read here rather than as a value of some name.
///
/// The `...` is what makes it a spread, and it may be padded with whitespace on
/// either side — what the expression is does not depend on the padding, since the
/// expression is trimmed either way.
fn parse_spread_attribute(
  src : StringView,
  offset : Int32,
) -> (Attribute, StringView) raise ParseError {
  let (text, rest) = scan_expression(src, offset)
  let spread = trim_space(text)
  if !spread.has_suffix("...") {
    raise ParseError(
      offset~,
      message="an attribute spread needs `...`, as in `{ attrs... }`",
    )
  }
  let value = trim_space(spread[:spread.length() - 3].to_owned())
  if value.is_empty() {
    raise ParseError(
      offset~,
      message="an attribute spread needs an expression: `{ ... }`",
    )
  }
  (Spread(value~), rest)
}

///|
fn parse_named_attribute(
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
    ['?', .. rest] => {
      let after_marker = match rest {
        ['=', '{', .. expr_src] => expr_src
        _ =>
          raise ParseError(
            offset~,
            message="a boolean expression attribute is written `" +
              name +
              "?={ expr }`",
          )
      }
      let (value, after) = scan_expression(after_marker, offset)
      (BoolExpression(name~, value~), after)
    }
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

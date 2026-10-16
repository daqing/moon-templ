///|
/// Read the head of a block: the text up to the `{` that opens it, the brace
/// itself, and the newline that has to follow it.
///
/// `keyword` names the statement in the messages — `if`, `for` — and `what` names
/// the text the head carries, a condition or a loop expression: a noun phrase
/// that reads with `a`, since that is how the messages use it. Spaces and tabs
/// may pad the brace, and it is free to stand on the line after the head — templ
/// reads a head with a Go parser that does not care where the line ends, so a
/// long one may be wrapped. What it may not do is share a line with the first
/// thing in the block: templ eats ` {\n` after every head, so a block always
/// starts on a line of its own.
fn open_block(
  src : StringView,
  offset : Int32,
  keyword~ : String,
  what~ : String,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  let at_brace = match scan_head(src, 0, buf, at_open_brace) {
    Some(rest) => rest
    None =>
      raise ParseError(
        offset~,
        message=keyword + ": missing '{' after the " + what,
      )
  }
  let head = trim_space(buf.to_string())
  if head.is_empty() {
    raise ParseError(
      offset~,
      message=keyword + ": expected a " + what + " before '{'",
    )
  }
  let after_brace = match take_spaces(at_brace) {
    ['{', .. rest] => take_spaces(rest)
    _ =>
      raise ParseError(
        offset~,
        message=keyword + ": expected '{' after the " + what,
      )
  }
  (head, take_block_newline(after_brace, offset, keyword~))
}

///|
/// The marker a statement's head ends at: the `{` that opens its block, which is
/// left where it stands for `open_block` to read.
fn at_open_brace(src : StringView) -> Bool {
  match src {
    ['{', ..] => true
    _ => false
  }
}

///|
/// The newline that has to follow a block's opening brace, so that the block
/// starts on a line of its own.
fn take_block_newline(
  after_brace : StringView,
  offset : Int32,
  keyword~ : String,
) -> StringView raise ParseError {
  match after_brace {
    ['\n', .. rest] => rest
    ['\r', '\n', .. rest] => rest
    _ =>
      raise ParseError(
        offset~,
        message=keyword +
          ": expected a newline after '{', so that the block starts on a line of its own",
      )
  }
}

///|
/// Whether `src` stands at the `}` that closes a block, which may be padded with
/// spaces or tabs.
fn at_close_brace(src : StringView) -> Bool {
  match take_spaces(src) {
    ['}', ..] => true
    _ => false
  }
}

///|
/// Consume the `}` that closes a block, padded or not.
fn close_brace(
  src : StringView,
  offset : Int32,
  keyword~ : String,
) -> StringView raise ParseError {
  match take_spaces(src) {
    ['}', .. rest] => rest
    _ =>
      raise ParseError(
        offset~,
        message=keyword + ": expected '}' to close the block",
      )
  }
}

///|
/// Parse an `if` statement: the condition, the block it opens, then any `else if`
/// branches and an `else`. `src` starts at the `if`.
///
/// templ reads the keyword as `if ` — space included — and insists on a newline
/// after the opening brace; both are what keep an `if` written in the middle of a
/// line, or on the same line as the brace, as text rather than as a statement.
///
/// The condition is copied through verbatim and neither parsed nor checked here:
/// the generated file hands it to the MoonBit compiler, which is the only thing
/// that knows what an expression may hold.
fn parse_if(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_if = drop_prefix(src, "if "[:])
  let (condition, after_open) = open_block(after_if, offset)
  let (then_nodes, at_close) = parse_nodes(
    after_open,
    offset + consumed(src, after_open),
    at_close_brace,
  )
  let (else_ifs, else_nodes, rest) = parse_branches(
    at_close,
    offset + consumed(src, at_close),
  )
  (If({ condition, then: then_nodes, else_ifs, else_: else_nodes, }), rest)
}

///|
/// Read the head of a branch: its condition, the `{` that opens the block, and
/// the newline that has to follow that brace.
///
/// Spaces and tabs may pad the brace, and it is free to stand on the line after
/// the condition — templ reads the condition with a Go parser that does not care
/// where the line ends, so a long condition may be wrapped. What it may not do is
/// share a line with the first thing in the block.
fn open_block(
  src : StringView,
  offset : Int32,
) -> (String, StringView) raise ParseError {
  let buf = StringBuilder()
  let at_brace = match scan_condition(src, 0, buf) {
    Some(rest) => rest
    None =>
      raise ParseError(offset~, message="if: missing '{' after the condition")
  }
  let condition = trim_space(buf.to_string())
  if condition.is_empty() {
    raise ParseError(offset~, message="if: expected a condition before '{'")
  }
  let after_brace = match take_spaces(at_brace) {
    ['{', .. rest] => take_spaces(rest)
    _ =>
      raise ParseError(offset~, message="if: expected '{' after the condition")
  }
  match after_brace {
    ['\n', .. rest] => (condition, rest)
    ['\r', '\n', .. rest] => (condition, rest)
    _ =>
      raise ParseError(
        offset~,
        message="if: expected a newline after '{', so that the block starts on a line of its own",
      )
  }
}

///|
/// Read what follows a branch's closing brace: another `else if`, an `else`, or
/// nothing at all.
///
/// Any whitespace may stand between the brace and the keyword, and between `else`
/// and its own brace — an `else {` needs no newline after it, unlike an `if`,
/// since templ reads its body as an ordinary node list. The `}` is consumed
/// either way, so the view that comes back stands after the statement.
fn parse_branches(
  at_close : StringView,
  offset : Int32,
) -> (Array[ElseIf], Array[Node], StringView) raise ParseError {
  parse_else_ifs(at_close, offset, [])
}

///|
/// The `else if` chain, one link at a time: each branch's closing brace is
/// consumed on the way to the next.
fn parse_else_ifs(
  at_close : StringView,
  offset : Int32,
  collected : Array[ElseIf],
) -> (Array[ElseIf], Array[Node], StringView) raise ParseError {
  let after_brace = close_brace(at_close, offset)
  let after_space = skip_space(after_brace)
  let at = offset + consumed(at_close, after_space)
  if after_space.has_prefix("else if"[:]) {
    // templ re-reads the head from the `if` of `else if` onwards, so a
    // condition may sit right against the keyword: `else if(x) {` parses.
    let (condition, after_open) = open_block(
      drop_prefix(after_space, "else if"[:]),
      at,
    )
    let body_at = at + consumed(after_space, after_open)
    let (nodes, close) = parse_nodes(after_open, body_at, at_close_brace)
    collected.push({ condition, then: nodes, })
    return parse_else_ifs(
      close,
      body_at + consumed(after_open, close),
      collected,
    )
  }
  match take_else(after_space) {
    Some(body) => {
      let body_at = at + consumed(after_space, body)
      let (nodes, close) = parse_nodes(body, body_at, at_close_brace)
      (collected, nodes, close_brace(close, body_at))
    }
    None => (collected, [], after_brace)
  }
}

///|
/// Consume the `else` of an else block and the `{` that opens it, with the
/// whitespace that may pad either. `None` when what stands here is not an else
/// block, in which case the statement has no `else` at all.
fn take_else(src : StringView) -> StringView? {
  match src {
    ['e', 'l', 's', 'e', .. rest] =>
      match take_spaces(skip_space(rest)) {
        ['{', .. rest] => Some(skip_space(rest))
        _ => None
      }
    _ => None
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
fn close_brace(src : StringView, offset : Int32) -> StringView raise ParseError {
  match take_spaces(src) {
    ['}', .. rest] => rest
    _ =>
      raise ParseError(offset~, message="if: expected '}' to close the block")
  }
}

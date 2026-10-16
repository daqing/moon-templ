///|
/// Parse a `match` statement: the subject, then the arms of its block. `src`
/// starts at the `match`.
///
/// This is templ's `switch`, written the way MoonBit writes it. templ reads a
/// `switch` head and then a flat list of `case x:` and `default:` cases, each
/// ending where the next one begins; a MoonBit arm ends at its own brace instead,
/// which is the one thing the two spellings cannot share. Everything else — a
/// newline after the opening brace, a body that is a block of nodes, a statement
/// that ends at its closing brace — is the same, and so is the whitespace that
/// falls out of it.
fn parse_match(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_match = drop_prefix(src, "match "[:])
  let (subject, after_open) = open_block(
    after_match,
    offset,
    keyword="match",
    what="subject",
  )
  let open_at = offset + consumed(src, after_open)
  let (arms, at_close) = parse_arms(after_open, open_at)
  let rest = close_brace(
    at_close,
    open_at + consumed(after_open, at_close),
    keyword="match",
  )
  (Match({ subject, arms, }), rest)
}

///|
/// Read the arms of a `match` block, up to the brace that closes it, which is left
/// where it stands.
///
/// The whitespace between two arms belongs to neither: templ reads it as padding
/// around a `case` keyword and throws it away, so each arm's body is a block body
/// and nothing stands between the arms.
fn parse_arms(
  at : StringView,
  offset : Int32,
) -> (Array[MatchArm], StringView) raise ParseError {
  let arms : Array[MatchArm] = []
  let rest = parse_arms_into(at, offset, arms)
  (arms, rest)
}

///|
fn parse_arms_into(
  at : StringView,
  offset : Int32,
  arms : Array[MatchArm],
) -> StringView raise ParseError {
  let after_space = skip_space(at)
  let spaced_at = offset + consumed(at, after_space)
  // Either the block is over or it is not — and when the source runs out first
  // there is no arm left to read, so the closing brace is what is missing and
  // saying so is the caller's job.
  if at_close_brace(after_space) || after_space.is_empty() {
    return after_space
  }
  let (arm, after_arm) = parse_arm(after_space, spaced_at)
  arms.push(arm)
  parse_arms_into(after_arm, spaced_at + consumed(after_space, after_arm), arms)
}

///|
/// Parse one arm: its pattern, the `=>`, and the block that holds its body.
fn parse_arm(
  src : StringView,
  offset : Int32,
) -> (MatchArm, StringView) raise ParseError {
  let buf = StringBuilder()
  let arrow_at = match scan_head(src, 0, buf, at_arrow) {
    Some(rest) => rest
    None =>
      raise ParseError(offset~, message="match: missing '=>' after the pattern")
  }
  let pattern = trim_space(buf.to_string())
  if pattern.is_empty() {
    raise ParseError(offset~, message="match: expected a pattern before '=>'")
  }
  let after_arrow = drop_prefix(arrow_at, "=>"[:])
  let after_brace = match take_spaces(after_arrow) {
    ['{', .. rest] => take_spaces(rest)
    _ =>
      raise ParseError(
        offset~,
        message="match: expected '{' after '=>', so that the arm holds a block of nodes",
      )
  }
  let body = take_block_newline(after_brace, offset, keyword="match")
  let body_at = offset + consumed(src, body)
  let (children, at_close) = parse_nodes(body, body_at, at_close_brace)
  let rest = close_brace(
    at_close,
    body_at + consumed(body, at_close),
    keyword="match",
  )
  ({ pattern, children, }, rest)
}

///|
/// The marker an arm's pattern ends at: the `=>` in front of its block, which is
/// left where it stands.
fn at_arrow(src : StringView) -> Bool {
  src.has_prefix("=>"[:])
}

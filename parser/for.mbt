///|
/// Parse a `for` statement: the head between the keyword and the block, then the
/// block itself. `src` starts at the `for`.
///
/// MoonBit writes a loop two ways, and both are templ's: `for i = 0; i < n; i = i
/// + 1` steps an index the way templ's C-style form does, and `for v in items`
/// walks a collection the way `for i, v := range items` does — the form templ
/// users write most, spelled the way MoonBit spells it.
///
/// The head is copied through verbatim and neither parsed nor checked here: the
/// generated file hands it to the MoonBit compiler, which is the only thing that
/// knows what a head may hold.
fn parse_for(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_for = drop_prefix(src, "for "[:])
  let (expression, after_open) = open_block(
    after_for,
    offset,
    keyword="for",
    what="loop expression",
  )
  let body_at = offset + consumed(src, after_open)
  let (children, at_close) = parse_nodes(after_open, body_at, at_close_brace)
  let rest = close_brace(
    at_close,
    body_at + consumed(after_open, at_close),
    keyword="for",
  )
  (For({ expression, children, }), rest)
}

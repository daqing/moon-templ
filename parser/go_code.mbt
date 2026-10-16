///|
/// Parse a `{{ code }}` block: MoonBit code that the generator writes into the
/// function body as it stands. templ's `{{ stmt }}` means the same thing over Go
/// code, which is why what goes in it is a statement — templ's `{{ x := 1 }}` is
/// MoonBit's `{{ let x = 1 }}`.
///
/// The braces may be padded with whitespace, and the code inside them is kept as
/// it stands apart from that padding: the generator has nowhere to put a comment
/// of its own, and the compiler that reads the generated file is the one that
/// checks the code.
///
/// The whitespace that follows the closing braces belongs to the block rather
/// than to the list around it. templ reads it into the node and never writes it
/// out again, so `a{{ x := 1 }} c` renders `"ac"` — the one place in templ where
/// whitespace between two nodes is simply lost.
fn parse_go_code(
  src : StringView,
  offset : Int32,
) -> (Node, StringView) raise ParseError {
  let after_open = drop_prefix(src, "{{"[:])
  // `scan_expression` stops at the first `}` that no `{` opened, which is the
  // first of the block's two closing braces — the second is the one left to read
  // here. A `}` of the code's own is either nested in a brace or inside a string,
  // so the view is past it either way.
  let (text, at_close) = scan_expression(after_open, offset)
  let after_close = match at_close {
    ['}', .. rest] => rest
    _ =>
      raise ParseError(
        offset~,
        message="go code: missing '}}' to close the block",
      )
  }
  (GoCode(trim_space(text)), scan_space_run(after_close))
}

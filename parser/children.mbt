///|
/// The source after a `{ children... }`, or `None` when the braces hold anything
/// else. Whitespace may pad the keyword on both sides, newlines included, but
/// nothing else may: `{ children }` and `{ children.. }` are expressions.
///
/// templ reads this form ahead of its general expression parser for the same
/// reason: `children...` is not an expression anyone could write, so the braces
/// have to be recognised as a whole.
fn match_children_expression(src : StringView) -> StringView? {
  let after_brace = match src {
    ['{', .. rest] => scan_space_run(rest)
    _ => return None
  }
  let keyword = "children..."[:]
  if !after_brace.has_prefix(keyword) {
    return None
  }
  match scan_space_run(drop_prefix(after_brace, keyword)) {
    ['}', .. rest] => Some(rest)
    _ => None
  }
}

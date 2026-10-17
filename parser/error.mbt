///|
/// A syntax error at a UTF-16 code-unit `offset` into the template source — the
/// unit `StringView::length` counts, which is how the parser walks the source.
pub(all) suberror ParseError {
  ParseError(offset~ : Int32, message~ : String)
} derive(Eq, Debug)

///|
pub extend ParseError with Eq::{equal, not_equal}

///|
pub extend ParseError with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// The 1-based line and column an `offset` into `source` points at, which is
/// what an editor jumps to from a `file:line:column` report. The column counts
/// Unicode characters rather than code units, so an offset after an emoji moves
/// the caret by one column, not two.
///
/// An offset past the end of the source points at the end, and one before the
/// start points at the beginning: a position is reported rather than refused.
pub fn line_column(source : String, offset : Int32) -> (Int32, Int32) {
  let end = if offset < 0 {
    0
  } else if offset > source.length() {
    source.length()
  } else {
    offset
  }
  let mut line = 1
  let mut column = 1
  let mut i = 0
  while i < end {
    let unit = source.unsafe_get(i)
    if unit.to_int() == 0x0A {
      line = line + 1
      column = 1
      i = i + 1
    } else if unit.is_leading_surrogate() &&
      i + 1 < end &&
      source.unsafe_get(i + 1).is_trailing_surrogate() {
      column = column + 1
      i = i + 2
    } else {
      column = column + 1
      i = i + 1
    }
  }
  (line, column)
}

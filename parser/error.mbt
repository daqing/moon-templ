///|
/// A syntax error at a byte-free character `offset` into the template source.
pub(all) suberror ParseError {
  ParseError(offset~ : Int32, message~ : String)
} derive(Eq, Debug)

///|
pub extend ParseError with Eq::{equal, not_equal}

///|
pub extend ParseError with @moonbitlang/core/debug.Debug::{to_repr}

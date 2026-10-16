///|
/// A template that parsed but cannot be turned into MoonBit source.
pub(all) suberror GenerateError {
  GenerateError(message~ : String)
} derive(Eq, Debug)

///|
pub extend GenerateError with Eq::{equal, not_equal}

///|
pub extend GenerateError with @moonbitlang/core/debug.Debug::{to_repr}

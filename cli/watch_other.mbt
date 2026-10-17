///|
/// A target without a clock has no way to wait between polls, so `run_generate`
/// refuses to watch there before the loop starts; this keeps the package
/// compiling for those targets all the same.
fn pause(_milliseconds : Int32) -> Unit raise CliError {
  raise CliError(message="watch mode needs the native target")
}

///|
fn watch_supported() -> Bool {
  false
}

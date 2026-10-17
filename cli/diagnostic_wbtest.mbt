///|
/// The error a failing generation of `source` raises, so a test can read what
/// the user would see. The path names no real file: a syntax error is found
/// before anything is written, so none is needed.
fn diagnostic_of(source : String) -> String {
  try {
    generate_source("page.templ", source) |> ignore
    "<no error>"
  } catch {
    CliError(message~) => message
  }
}

///|
/// A syntax error names where in the file it is, as `file:line:column`, which is
/// the form editors turn into a clickable position.
test "a syntax error is reported at its line and column" {
  assert_eq(
    diagnostic_of("templ a() {\n  <div>\n  <p>\n  </div>\n}"),
    "page.templ:4:3: element name must start with a lowercase letter: /",
  )
}

///|
/// The line is counted from the start of the file, not from the start of the
/// template block the error is in.
test "the position is counted from the start of the file" {
  assert_eq(
    diagnostic_of("// header\ntempl a() {\n  <div>\n  <p>\n  </div>\n}"),
    "page.templ:5:3: element name must start with a lowercase letter: /",
  )
  assert_eq(
    diagnostic_of("templ a() {\n  <div>\n"),
    "page.templ:2:3: unclosed element <div>",
  )
}

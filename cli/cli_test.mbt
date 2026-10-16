///|
/// The error a failing call raises, so a test can read what the user would see.
fn message_of(result : () -> Unit raise @cli.CliError) -> String {
  try {
    result()
    "<no error>"
  } catch {
    @cli.CliError(message~) => message
  }
}

///|
test "the output file sits beside the template, named after it" {
  assert_eq(@cli.output_path("hello.templ"), "hello_templ.mbt")
  assert_eq(
    @cli.output_path("examples/hello/hello.templ"),
    "examples/hello/hello_templ.mbt",
  )
}

///|
test "a name that is not a template keeps its own extension" {
  assert_eq(@cli.output_path("hello"), "hello_templ.mbt")
  assert_eq(@cli.output_path("hello.html"), "hello.html_templ.mbt")
}

///|
test "a file that cannot be read is named in the error" {
  let message = message_of(fn() raise @cli.CliError {
    @cli.generate_file("no-such-template.templ") |> ignore
  })
  assert_true(message.contains("no-such-template.templ"))
  assert_true(message.contains("cannot read"))
}

///|
test "no arguments prints the usage and fails" {
  assert_eq(@cli.run([]), 1)
}

///|
test "an unknown command is refused" {
  assert_eq(@cli.run(["moon-templ", "frobnicate"]), 1)
}

///|
test "generate without a file is a usage error" {
  assert_eq(@cli.run(["moon-templ", "generate"]), 1)
}

///|
test "generate with more than one file is a usage error" {
  assert_eq(@cli.run(["moon-templ", "generate", "a.templ", "b.templ"]), 1)
}

///|
test "a file that cannot be read fails the command" {
  assert_eq(@cli.run(["moon-templ", "generate", "no-such-template.templ"]), 1)
}

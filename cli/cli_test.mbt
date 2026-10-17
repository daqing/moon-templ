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

///|
test "fmt without a file is a usage error" {
  assert_eq(@cli.run(["moon-templ", "fmt"]), 1)
}

///|
test "fmt with more than one file is a usage error" {
  assert_eq(@cli.run(["moon-templ", "fmt", "a.templ", "b.templ"]), 1)
}

///|
test "fmt on a file that cannot be read fails the command" {
  assert_eq(@cli.run(["moon-templ", "fmt", "no-such-template.templ"]), 1)
}

///|
test "fmt over a directory with no templates fails" {
  assert_eq(@cli.run(["moon-templ", "fmt", "parser"]), 1)
}

///|
/// `./...` is the spelling the Go tools use for a whole tree, and a bare
/// directory names one too; anything else is a single file.
test "a tree argument names a directory, not a file" {
  assert_true(@cli.is_tree_argument("./..."))
  assert_true(@cli.is_tree_argument("examples/..."))
  assert_true(@cli.is_tree_argument("..."))
  assert_false(@cli.is_tree_argument("examples"))
  assert_false(@cli.is_tree_argument("hello.templ"))
  assert_false(@cli.is_tree_argument("examples/hello/hello.templ"))
}

///|
test "a tree argument's root is the directory it spells" {
  assert_eq(@cli.tree_root("./..."), ".")
  assert_eq(@cli.tree_root("examples/..."), "examples")
  assert_eq(@cli.tree_root("a/b/c/..."), "a/b/c")
  assert_eq(@cli.tree_root("..."), ".")
}

///|
/// The walk reaches into subdirectories, and reports what it finds in name
/// order so a batch reads the same way on every run.
test "the walk finds every template under a directory" {
  assert_eq(@cli.templ_files_under("examples"), [
    "examples/hello/hello.templ", "examples/site/layout.templ", "examples/site/page.templ",
    "examples/site/ui/card.templ",
  ])
  assert_eq(@cli.templ_files_under("examples/site"), [
    "examples/site/layout.templ", "examples/site/page.templ", "examples/site/ui/card.templ",
  ])
  assert_eq(@cli.templ_files_under("examples/site/ui"), [
    "examples/site/ui/card.templ",
  ])
}

///|
test "a directory with no templates holds none" {
  assert_eq(@cli.templ_files_under("parser"), [])
  assert_eq(@cli.templ_files_under("generator"), [])
}

///|
test "a directory that cannot be read is named in the error" {
  let message = message_of(fn() raise @cli.CliError {
    @cli.templ_files_under("no-such-dir") |> ignore
  })
  assert_true(message.contains("no-such-dir"))
  assert_true(message.contains("cannot read"))
}

///|
/// A batch over a directory that holds nothing to generate has nothing to do,
/// and says so rather than reporting success for a path the user mistyped. The
/// directory here is real, so this is the same refusal a typo earns.
test "a batch over a directory with no templates fails" {
  assert_eq(@cli.run(["moon-templ", "generate", "parser"]), 1)
  assert_eq(@cli.run(["moon-templ", "generate", "no-such-dir/..."]), 1)
}

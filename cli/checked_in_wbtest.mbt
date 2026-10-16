///|
fn generated_source_of(path : String) -> String raise {
  let source = @fs.read_file_to_string(path)
  @generator.generate(@parser.parse_template_file(source)).source
}

///|
/// Every template the repository checks in: the examples, which a reader starts
/// from, and the goldens ported from templ, which the render tests are asserted
/// against. Both carry their generated files for the same reason a project does
/// — a fresh clone builds and runs them without running the generator first.
fn checked_in_templates() -> Array[String] {
  [
    "examples/hello/hello.templ", "examples/site/layout.templ", "examples/site/page.templ",
    "examples/site/ui/card.templ", "golden/call/call.templ", "golden/class/class.templ",
    "golden/for/for.templ", "golden/if/if.templ", "golden/style/style.templ", "golden/url/url.templ",
  ]
}

///|
/// The directories those templates live in. The repository root is not one of
/// them: it holds the build directory and the downloaded dependencies, and a
/// `.templ` file in there is not one of ours.
fn template_roots() -> Array[String] {
  ["examples", "golden"]
}

///|
/// Each template is checked in with the file the generator writes for it, and
/// that only holds while the committed file is what the generator writes today.
/// This reads the committed file back rather than regenerating it in place, so
/// drift fails here instead of being quietly overwritten.
test "the checked-in generated files are what the generator writes today" {
  for template in checked_in_templates() {
    assert_eq(
      generated_source_of(template),
      @fs.read_file_to_string(output_path(template)),
    )
  }
}

///|
/// Each template in the tree is one the list above names. A template nobody adds
/// to the list would be checked in and never checked, and one moved or renamed
/// would leave the list naming a file that is not there.
test "every template in the tree is one of the ones checked" {
  let found : Array[String] = []
  for root in template_roots() {
    let under = templ_files_under(root) catch {
      CliError(message~) => fail(message)
    }
    for path in under {
      found.push(path)
    }
  }
  let expected = checked_in_templates()
  found.sort_by(fn(a, b) { a[:].lexical_compare(b[:]) })
  expected.sort_by(fn(a, b) { a[:].lexical_compare(b[:]) })
  assert_eq(found, expected)
}

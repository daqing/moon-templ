///|
fn generated_source_of(path : String) -> String raise {
  let source = @fs.read_file_to_string(path)
  @generator.generate(@parser.parse_template_file(source)).source
}

///|
/// Every template the repository checks in. The examples carry their generated
/// files for the same reason a project does: a fresh clone builds and runs them
/// without running the generator first.
fn example_templates() -> Array[String] {
  [
    "examples/hello/hello.templ", "examples/site/layout.templ", "examples/site/page.templ",
    "examples/site/ui/card.templ",
  ]
}

///|
/// Each example is checked in with the file the generator writes for it, and that
/// only holds while the committed file is what the generator writes today. This
/// reads the committed file back rather than regenerating it in place, so drift
/// fails here instead of being quietly overwritten.
test "the committed examples are what the generator writes today" {
  for template in example_templates() {
    assert_eq(
      generated_source_of(template),
      @fs.read_file_to_string(output_path(template)),
    )
  }
}

///|
/// Each example is one the walk that generates them reaches. An example that
/// nobody adds to the list would be checked in and never checked, and a template
/// moved or renamed would leave the list naming a file that is not there.
test "every template in the tree is one of the examples checked" {
  let found = templ_files_under("examples") catch {
    CliError(message~) => fail(message)
  }
  let expected = example_templates()
  found.sort_by(fn(a, b) { a[:].lexical_compare(b[:]) })
  expected.sort_by(fn(a, b) { a[:].lexical_compare(b[:]) })
  assert_eq(found, expected)
}

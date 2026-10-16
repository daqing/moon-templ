///|
fn generated_source_of(path : String) -> String raise {
  let source = @fs.read_file_to_string(path)
  @generator.generate(@parser.parse_template_file(source)).source
}

///|
/// `examples/hello` is checked in with its generated file, so a fresh clone
/// builds a working example without running the generator first. That only holds
/// while the committed file is what the generator writes today — this reads it
/// back rather than regenerating it in place, so drift fails here instead of
/// being quietly overwritten.
test "the committed example is what the generator writes today" {
  assert_eq(
    generated_source_of("examples/hello/hello.templ"),
    @fs.read_file_to_string("examples/hello/hello_templ.mbt"),
  )
}

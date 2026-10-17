///|
/// The repository's own templates are written the way the formatter writes, so
/// formatting them has nothing to say. A failure here names the file and shows
/// the two texts, which is the diff a reader needs.
test "the checked-in templates are already formatted" {
  for template in checked_in_templates() {
    let source = @fs.read_file_to_string(template)
    assert_eq(@formatter.format_source(source), source, msg=template)
  }
}

///|
test "formatting is idempotent" {
  for template in checked_in_templates() {
    let source = @fs.read_file_to_string(template)
    let once = @formatter.format_source(source)
    assert_eq(@formatter.format_source(once), once, msg=template)
  }
}

///|
/// Formatting changes the layout of a template, never what it renders: the
/// generated file for the formatted text is the one for the original.
test "formatting keeps the generated file unchanged" {
  for template in checked_in_templates() {
    let source = @fs.read_file_to_string(template)
    let formatted = @formatter.format_source(source)
    let before = @generator.generate(@parser.parse_template_file(source)).source
    let after = @generator.generate(@parser.parse_template_file(formatted)).source
    assert_eq(after, before, msg=template)
  }
}

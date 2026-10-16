///|
/// templ's `generator/test-class-whitespace` golden, whose `expected.html` is
/// one `<div>` per template with the spaces of each class list squeezed to one.
///
/// The golden spells the fifth `<div>`'s name `class`, while the generator
/// writes it `CLASS`, the case it was read with — templ's own generated Go
/// writes it that way too, and the file's spelling is the HTML difference
/// printer's, which reads both as the same attribute.
///
/// The last template's attribute is named `data-class` and is not a class list:
/// whatever the case of the name, only `class` itself is one.
///
/// The golden's own `TestComponent` is ported whole, and the two templates the
/// golden has no case for — a class list written as an expression, and an
/// expression the generator leaves alone — are added beside it.
test "a class list renders as one space between its names" {
  assert_eq(
    test_component().to_string(),
    "<div class=\"flex w-full h-full justify-center items-center hover:bg-blue-50\">" +
    "Multiline class attribute</div>" +
    "<div class=\"a b c\">Extra spaces between classes</div>" +
    "<div class=\"a b c\">Leading and trailing spaces</div>" +
    "<div class=\"a b c\">Tabs and newlines</div>" +
    "<div CLASS=\"a b c\">Uppercase CLASS attribute</div>" +
    "<div data-class=\"a  b  c\">Non-class attributes unchanged</div>",
  )
}

///|
/// The other half of a class attribute, which the golden does not reach: a value
/// written as an expression is a `CSSClasses` the caller builds, and the list it
/// renders is the one above — a flag that is off takes its name out, and the
/// names that are left keep the order they were given in.
test "a class list written as an expression renders the same way" {
  assert_eq(
    expression_class_list(true).to_string(),
    "<div class=\"always sometimes\">Expression class list</div>",
  )
  assert_eq(
    expression_class_list(false).to_string(),
    "<div class=\"always\">Expression class list</div>",
  )
}

///|
/// Only a constant class attribute is collapsed — the collapse is templ's
/// `strings.Fields` over a value the generator can read, and an expression is not
/// one. templ renders a string handed to `CSSClasses` as a single name, so the
/// spaces inside it are its own and stay.
test "an expression class value is not collapsed" {
  assert_eq(
    expression_string_is_one_name().to_string(),
    "<div class=\"a  b\">An expression class list is not a constant</div>",
  )
}

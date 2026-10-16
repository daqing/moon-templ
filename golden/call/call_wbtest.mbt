///|
/// templ's `generator/test-call` golden covers what a call may be: a call with
/// no arguments, a call whose argument is another component, a component passed
/// as a parameter and rendered, and a call whose block becomes the component's
/// children. Each one writes its own markup and nothing else, so the six pieces
/// land one after another with nothing in between.
///
/// One thing is not ported: templ's `showAll` is spelled with capitals, and a
/// MoonBit function name may not start with one, so every template here is
/// snake_case (T2.18).
test "a call renders the component it names" {
  assert_eq(
    show_all().to_string(),
    "<div>A</div><div>B</div><div>C</div><div>Legacy call style</div>" +
    "<div>e</div><div id=\"wrapper\"><div>Child content</div></div>",
  )
}

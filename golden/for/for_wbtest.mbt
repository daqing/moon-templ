///|
/// templ's `generator/test-for` golden, whose `expected.html` is one `<div>` per
/// item.
///
/// The golden file puts each `<div>` on a line of its own, which is how templ's
/// HTML differ prints block elements it is handed; the rendering itself has the
/// tags of one iteration against the next, because the whitespace that separates
/// them in the source leads and trails the loop body and so belongs to the body
/// rather than to the document.
test "a for renders its body once per item" {
  assert_eq(
    render(["a", "b", "c"]).to_string(),
    "<div>a</div><div>b</div><div>c</div>",
  )
}

///|
/// templ's conditional attributes — `if expr { attrs } else { attrs }` written
/// inside a start tag, which is the one place a tag decides for itself which
/// attributes it carries.
///
/// The template is the six elements of templ's `generator/test-conditional-attributes`
/// in the same order: an `if` on its own, an `if` with an `else`, an `else` holding
/// a constant where the `if` holds an expression URL, a conditional between two
/// ordinary attributes, one conditional nested in another, and a boolean and a
/// constant attribute as the two branches. Both outcomes of every condition are
/// asserted, and both strings are what real templ renders for the same template
/// with the same arguments — `u` is `"/a?x=1"`, a URL that passes the whitelist
/// as it stands, so the attribute shows the sanitizing and the escaping of the
/// ordinary path at once.
test "a conditional attribute is written when its condition is true" {
  assert_eq(
    conditional_attributes(true, "/a?x=1").to_string(),
    "<div><div class=\"on\"></div><div class=\"on\"></div>" +
    "<a href=\"/a?x=1\">link</a><div id=\"x\" class=\"yes\" data-k=\"v\"></div>" +
    "<div class=\"a\" title=\"t\"></div><button disabled>b</button></div>",
  )
}

///|
/// The other side: each `else` takes over from the `if` that came before it, and
/// a block with no `else` leaves the attribute out entirely — the `<div>` of the
/// first line and the one before `data-k` carry nothing but what stands outside
/// the block.
test "a conditional attribute writes its else branch when the condition is false" {
  assert_eq(
    conditional_attributes(false, "/a?x=1").to_string(),
    "<div><div></div><div class=\"off\"></div>" +
    "<a href=\"/b\">link</a><div id=\"x\" data-k=\"v\"></div>" +
    "<div></div><button type=\"button\">b</button></div>",
  )
}

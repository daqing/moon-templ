///|
/// templ's `generator/test-html`, the three `<hr>` lines of it that carry a
/// `name?={ expr }` attribute — the rest of that golden is the `templ.URL` and
/// class side already covered by `golden/url` and `golden/class`.
///
/// Both branches are asserted, and both are what real templ renders for the same
/// template with the same argument: a false attribute is gone entirely, separator
/// along with it, so nothing is left between the attributes around it.
test "a boolean expression attribute is written when its expression is true" {
  assert_eq(
    bool_expression_attributes(true).to_string(),
    "<hr noshade>" + "<hr optionA optionB optionC=\"other\">" + "<hr noshade>",
  )
}

///|
/// The false side, where the attribute an expression refuses leaves no trace: the
/// `optionD` of the second element is gone while `optionA` and `optionC` around it
/// stay.
test "a boolean expression attribute is left out when its expression is false" {
  assert_eq(
    bool_expression_attributes(false).to_string(),
    "<hr>" + "<hr optionA optionC=\"other\" optionD>" + "<hr noshade>",
  )
}

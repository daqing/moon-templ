///|
/// templ's `generator/test-a-href` and `generator/test-form-action` goldens,
/// whose `expected.html` files say the same three things each: a constant URL is
/// written as it was authored, an expression URL naming `javascript:` comes out
/// as the failed-sanitization URL, and a `templ.SafeURL` — the type that says the
/// template vouches for the value — comes out as written.
///
/// The goldens compare by HTML diff, so their files are laid out the way a reader
/// would write them; what they render is below. templ's `templ.URL` and
/// `templ.SafeURL` are `@rt.url` and `@rt.SafeURL::new` here, and the two Go
/// helpers of the form golden are two templates' worth of `safe_url` and
/// `string_url`, which differ in no way but the type they return.
///
/// The two templates the goldens do not have cover the rest of the rule: `href`
/// on a `<link>`, `data` on an `<object>`, and the negative — `src` is on no
/// element's list, and a `title` is not a URL, so both are escaped and neither is
/// whitelisted. Real templ was run against all of them to check.
test "a url attribute is sanitized and a safe url is not" {
  assert_eq(
    render().to_string(),
    "<a href=\"javascript:alert('unaffected');\">Ignored</a> " +
    "<a href=\"about:invalid#TemplFailedSanitizationURL\">Sanitized</a> " +
    "<a href=\"javascript:alert(&#39;should not be sanitized&#39;)\">Unsanitized</a>",
  )
  assert_eq(
    render_form().to_string(),
    "<form action=\"javascript:alert('unaffected');\">Ignored</form>" +
    "<form action=\"about:invalid#TemplFailedSanitizationURL\">Sanitized</form>" +
    "<form action=\"javascript:alert(&#39;should not be sanitized&#39;)\">Unsanitized</form>" +
    "<form action=\"javascript:alert(&#39;should not be sanitized&#39;)\">with error unsanitized</form>" +
    "<form action=\"about:invalid#TemplFailedSanitizationURL\">with error sanitized</form>",
  )
  assert_eq(
    render_link_and_object().to_string(),
    "<link href=\"about:invalid#TemplFailedSanitizationURL\">" +
    "<object data=\"about:invalid#TemplFailedSanitizationURL\"></object>",
  )
  assert_eq(
    render_other_attributes().to_string(),
    "<img src=\"about:invalid#TemplFailedSanitizationURL\"> " +
    "<a title=\"javascript:alert(&#39;title&#39;)\">Other</a>",
  )
}

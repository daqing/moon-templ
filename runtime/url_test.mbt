///|
/// The whitelist, case by case. Every pair below is what templ's `URL` answers
/// for the same input, taken from a run of the real function.
///
/// The scheme is the text before the *first* `:`, and it only counts as a scheme
/// when no `/` comes before it — so `/a:b` and `a/b:c` are paths that a colon
/// happens to fall in, while `?a=b:c` and `#a:b` are read as scheme `?a=b` and
/// `#a:b`, neither of which is one of the six.
test "a url names a scheme templ knows, or it is refused" {
  let cases : Array[(String, String)] = [
    ("", ""),
    ("http://example.com", "http://example.com"),
    ("https://example.com", "https://example.com"),
    ("HTTP://EXAMPLE.COM", "HTTP://EXAMPLE.COM"),
    ("HtTpS://x", "HtTpS://x"),
    ("mailto:a@b.c", "mailto:a@b.c"),
    ("MAILTO:a@b.c", "MAILTO:a@b.c"),
    ("mailto:a@b.c?subject=x", "mailto:a@b.c?subject=x"),
    ("tel:+1234", "tel:+1234"),
    ("tel:", "tel:"),
    ("ftp://x", "ftp://x"),
    ("ftps://x", "ftps://x"),
    ("https:x", "https:x"),
    ("http:", "http:"),
    ("http:/single-slash", "http:/single-slash"),
    ("http://example.com:8080/a?b=c#d", "http://example.com:8080/a?b=c#d"),
    ("javascript:alert(1)", "about:invalid#TemplFailedSanitizationURL"),
    ("JAVASCRIPT:alert(1)", "about:invalid#TemplFailedSanitizationURL"),
    ("JavaScript:alert(1)", "about:invalid#TemplFailedSanitizationURL"),
    ("jAvAsCrIpT:x", "about:invalid#TemplFailedSanitizationURL"),
    ("vbscript:x", "about:invalid#TemplFailedSanitizationURL"),
    ("about:blank", "about:invalid#TemplFailedSanitizationURL"),
    (
      "data:text/html,<script>alert(1)</script>", "about:invalid#TemplFailedSanitizationURL",
    ),
    ("file:///etc/passwd", "about:invalid#TemplFailedSanitizationURL"),
    (
      "blob:https://example.com/uuid", "about:invalid#TemplFailedSanitizationURL",
    ),
    ("chrome://settings", "about:invalid#TemplFailedSanitizationURL"),
    ("a:b", "about:invalid#TemplFailedSanitizationURL"),
    ("x:y:z", "about:invalid#TemplFailedSanitizationURL"),
    ("hh:", "about:invalid#TemplFailedSanitizationURL"),
    (":x", "about:invalid#TemplFailedSanitizationURL"),
    (":", "about:invalid#TemplFailedSanitizationURL"),
    ("  http://x", "about:invalid#TemplFailedSanitizationURL"),
    ("?a=b:c", "about:invalid#TemplFailedSanitizationURL"),
    ("#a:b", "about:invalid#TemplFailedSanitizationURL"),
    ("/path", "/path"),
    ("path/to", "path/to"),
    ("/a:b", "/a:b"),
    ("./a:b", "./a:b"),
    ("a/b:c", "a/b:c"),
    ("//example.com/a", "//example.com/a"),
    ("//javascript:alert(1)", "//javascript:alert(1)"),
  ]
  for pair in cases {
    let (input, expected) = pair
    assert_eq(@runtime.url(input).to_string(), expected)
  }
}

///|
/// The whole point: what a `href` is handed goes through the whitelist, so a
/// `javascript:` cannot reach the browser.
test "a javascript url is refused" {
  assert_eq(
    @runtime.sanitize_url("javascript:alert('x')"),
    "about:invalid#TemplFailedSanitizationURL",
  )
  assert_eq(
    @runtime.sanitize_url(@runtime.url("javascript:alert('x')")),
    "about:invalid#TemplFailedSanitizationURL",
  )
}

///|
/// A `SafeURL` is not put through the whitelist — the type is what says the
/// value was vouched for — but it is still escaped for its place in the
/// attribute, which is why the apostrophes of a `javascript:` come out as
/// entities. templ renders this exact pair this way.
test "a safe url is escaped but not sanitized" {
  assert_eq(
    @runtime.sanitize_url(
      @runtime.SafeURL::new("javascript:alert('should not be sanitized')"),
    ),
    "javascript:alert(&#39;should not be sanitized&#39;)",
  )
  assert_eq(
    @runtime.sanitize_url("<a href=\"x\">"),
    "&lt;a href=&#34;x&#34;&gt;",
  )
}

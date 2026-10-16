///|
/// A URL the caller vouches for: templ's `templ.SafeURL`. A value of this type
/// goes into its attribute as it was given — `sanitize_url` leaves it alone —
/// which is the point of the type: a template that knows where its URL came from
/// says so, and one that does not hands over a string.
pub(all) struct SafeURL {
  priv value : String
}

///|
pub fn SafeURL::new(value : String) -> SafeURL {
  { value, }
}

///|
/// The URL as it stands, unescaped — templ's `templ.SafeURL` is a string type,
/// so `string(u)` is this. Whatever it lands in escapes it: the URL attribute
/// through `sanitize_url`, any other through `resolve_attribute_value`.
pub impl Show for SafeURL with fn output(self, logger) {
  logger.write_string(self.value)
}

///|
pub extend SafeURL with Show::{to_string, output}

///|
/// What a URL that fails the whitelist becomes: templ's `FailedSanitizationURL`,
/// a URL no browser follows and no template author misses in the output.
pub fn failed_sanitization_url() -> SafeURL {
  SafeURL::new("about:invalid#TemplFailedSanitizationURL")
}

///|
/// The six schemes templ lets a URL name, compared without regard to case, as it
/// compares them.
fn is_safe_scheme(scheme : String) -> Bool {
  match scheme.to_lower() {
    "http" | "https" | "mailto" | "tel" | "ftp" | "ftps" => true
    _ => false
  }
}

///|
/// templ's `URL`: a URL naming one of the six schemes it knows is handed back,
/// and one naming any other becomes the failed-sanitization URL — a
/// `javascript:` is exactly what this is here to stop.
///
/// A scheme is the text before the first `:`, and only counts as one when no `/`
/// comes before it: `a/b:c` is a path with a colon in it, not a scheme named
/// `a/b`.
pub fn url(value : String) -> SafeURL {
  match value.find(":") {
    Some(index) => {
      let scheme = value[:index].to_owned()
      if !scheme.contains("/") && !is_safe_scheme(scheme) {
        return failed_sanitization_url()
      }
      SafeURL::new(value)
    }
    None => SafeURL::new(value)
  }
}

///|
/// What a `href={ ... }`, `action={ ... }` or `data={ ... }` may hold. templ's
/// `JoinURLErrs[T ~string]` takes any string type and asks at run time whether
/// the value is already a `SafeURL`; here the value says which it is through
/// this trait, and a template's own type says the same by implementing it.
///
/// The check templ makes at run time is the one that keeps a `SafeURL` out of
/// the whitelist — `templ.SafeURL("javascript:…")` is rendered as written — and
/// that is what the two implementations below say: a string is a URL to be
/// sanitized, a `SafeURL` is one already.
pub(open) trait AsURL {
  fn as_url(Self) -> SafeURL
}

///|
pub impl AsURL for String with fn as_url(self) {
  url(self)
}

///|
pub impl AsURL for SafeURL with fn as_url(self) {
  self
}

///|
pub extend SafeURL with AsURL::{as_url}

///|
/// The value of a URL attribute, ready to be written between its quotes: the URL
/// the value resolves to, escaped. templ escapes it too — its generator writes
/// `EscapeString` around the `SafeURL` it resolved — so the apostrophes of a
/// `javascript:` that a `SafeURL` let through come out as `&#39;`.
pub fn[A : AsURL] sanitize_url(v : A) -> String {
  escape(v.as_url().value)
}

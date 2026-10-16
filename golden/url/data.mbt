///|
/// What templ's `safeUrl` answers: a URL the template vouches for, since it
/// knows where the value came from. templ's version returns an error beside it,
/// which only the generated error handling distinguishes — there is no error
/// here, and a call that fails is not one this port has.
pub fn safe_url(value : String) -> @rt.SafeURL {
  @rt.SafeURL::new(value)
}

///|
/// What templ's `stringUrl` answers: a URL the template does not vouch for, so
/// it goes through the whitelist like any other string.
pub fn string_url(value : String) -> String {
  value
}

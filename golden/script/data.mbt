///|
/// The calls the golden's templates are handed, written out as templ's
/// `templ.SafeScript` builds them: every parameter is JSON encoded, and the whole
/// call is escaped for the attribute it lands in — which is why the quotes of a
/// string parameter arrive as `&#34;`.
///
/// A `script` block is what normally builds one of these, and that is T6.2.
/// Until then a call is written out by hand, which is what a template author does
/// anyway with templ's `templ.ComponentScript{Call: …}` literal.
pub fn with_parameters() -> @rt.ComponentScript {
  @rt.ComponentScript::new(
    "__templ_withParameters_1056(&#34;test&#34;,&#34;A&#34;,123)",
  )
}

///|
pub fn without_parameters() -> @rt.ComponentScript {
  @rt.ComponentScript::new("__templ_withoutParameters_6bbf()")
}

///|
pub fn when_button_is_clicked() -> @rt.ComponentScript {
  @rt.ComponentScript::new("__templ_whenButtonIsClicked_253e(event)")
}

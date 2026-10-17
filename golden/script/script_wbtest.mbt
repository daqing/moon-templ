///|
/// templ's `generator/test-script-usage`, minus the `script` blocks it is built
/// around: what a `script` block *is* — a function, a call, and the `<script>`
/// definition that has to reach the page before the call does — is T6.2. What is
/// here is the attribute rule of T4.6, which those definitions are used through: a
/// name that starts with `on` or `hx-on:` holds a script's call rather than a
/// value, and the call goes in as it stands.
///
/// Each rendering below is what real templ renders for the same shape, with the
/// same calls templ's `SafeScript` builds for the script blocks of that golden.
/// Every expectation is byte for byte, whitespace between the elements included.
test "a script attribute holds the script's call" {
  assert_eq(
    button("A", with_parameters(), without_parameters()).to_string(),
    "<button onClick=\"__templ_withParameters_1056(&#34;test&#34;,&#34;A&#34;,123)\"" +
    " onMouseover=\"__templ_withoutParameters_6bbf()\" type=\"button\">A</button>",
  )
}

///|
/// The call is not escaped again. templ's `SafeScript` escapes each parameter for
/// the attribute it lands in, and the writer that follows writes the call out as
/// it stands — so the `&` of an `&#34;` stays an `&`, and a second escaping pass by
/// whoever reads it would show up here as `&amp;#34;`.
test "a script attribute does not escape the call a second time" {
  assert_eq(
    button("B", when_button_is_clicked(), without_parameters()).to_string(),
    "<button onClick=\"__templ_whenButtonIsClicked_253e(event)\"" +
    " onMouseover=\"__templ_withoutParameters_6bbf()\" type=\"button\">B</button>",
  )
}

///|
/// The two names a reader is most likely to write, and the two spellings of an
/// `hx-on:` attribute: `hx-on::click` is one attribute name, colons and all, and
/// both it and a plain `onclick` hold a call.
test "an event attribute of either spelling holds a call" {
  assert_eq(
    event_attributes(when_button_is_clicked()).to_string(),
    "<button hx-on::click=\"__templ_whenButtonIsClicked_253e(event)\" type=\"button\">" +
    "Button E</button> <button onclick=\"__templ_whenButtonIsClicked_253e(event)\">" +
    "Button F</button>",
  )
}

///|
/// A constant is written as it was read, as a constant style attribute is: templ
/// only reads a value an expression produced. Its script-usage golden has both of
/// these buttons, and both come out as their author wrote them.
test "a constant script attribute is written as it was read" {
  assert_eq(
    constants().to_string(),
    "<button onMouseover=\"console.log('mouseover')\" type=\"button\">Button C</button>" +
    " <button hx-on::click=\"alert('clicked inline')\" type=\"button\">Button D</button>",
  )
}

///|
/// The name is not folded, which is the negative of the rule: `OnClick` is not a
/// script attribute and `data-on` is not one either, so both are escaped values.
/// templ reads them the same way — its `isScriptAttribute` is a prefix test on the
/// name as it was written, so a capital `On` is not the prefix it looks for.
///
/// The divergence worth knowing: templ's `ResolveAttributeValue` has a
/// `case ComponentScript` handing a call over unescaped, which is how its
/// `OnClick={ handler }` renders the same thing its `onclick` does. Here a
/// `ComponentScript` is not an attribute value at all, so that template is refused
/// when it is compiled rather than rendering a call into an attribute whose name
/// does not say the value is one.
test "an attribute name that does not start with on is an escaped value" {
  assert_eq(
    case_folding("a<b").to_string(),
    "<button OnClick=\"a&lt;b\">Upper</button> <button data-on=\"a&lt;b\">Data</button>",
  )
}

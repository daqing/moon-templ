///|
/// A script a template calls from an event attribute: templ's
/// `templ.ComponentScript`.
///
/// `call` is the JavaScript that invokes the function — name, parameters and all
/// — and it is written into the attribute as it stands. Nothing escapes it
/// again, because the parameters were escaped when the call was built, which is
/// why the quotes of a string parameter arrive as `&#34;`.
///
/// templ's `Name`, `Function` and `CallInline` are what a `script` block needs
/// to be defined and rendered, and `RenderScriptItems` is how those definitions
/// reach the page. Neither is here yet: this type is what an event attribute's
/// expression is expected to be, and T6.2 is where a `script` block becomes one.
pub(all) struct ComponentScript {
  call : String
}

///|
pub fn ComponentScript::new(call : String) -> ComponentScript {
  { call, }
}

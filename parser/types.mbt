///|
/// A node inside a template body. Recursive through `Element`.
pub(all) enum Node {
  /// `<!doctype ...>`, carrying what sits between the keyword and `>` — `html`
  /// for the usual one.
  DocType(String)
  /// `<!-- ... -->`, carrying what sits between the delimiters.
  HTMLComment(String)
  Element(Element)
  RawElement(RawElement)
  Text(String)
  StringExpression(String)
} derive(Debug, Eq)

///|
pub(all) struct Element {
  name : String
  attrs : Array[Attribute]
  children : Array[Node]
  self_closing : Bool
} derive(Debug, Eq)

///|
/// An element whose contents are not template syntax. `<style>` and `<script>`
/// keep whatever sits between their tags verbatim, so a `{` in CSS or a `<` in
/// JavaScript is neither an expression nor a tag.
pub(all) struct RawElement {
  name : String
  attrs : Array[Attribute]
  contents : String
} derive(Debug, Eq)

///|
pub(all) enum Attribute {
  Constant(name~ : String, value~ : String)
  Bool(name~ : String)
} derive(Debug, Eq)

///|
/// A `templ Name(params) { ... }` block. `params` keeps the source spelling of
/// the parameter list, e.g. `name : String`, and is copied verbatim into the
/// generated function header. `receiver` holds the `templ (self : T) Name()`
/// form the same way, and is empty for a plain function.
pub(all) struct Template {
  name : String
  receiver : String
  params : String
  nodes : Array[Node]
} derive(Debug, Eq)

///|
pub(all) struct TemplateFile {
  templates : Array[Template]
} derive(Debug, Eq)

///|
pub extend Node with Eq::{equal, not_equal}

///|
pub extend Node with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Element with Eq::{equal, not_equal}

///|
pub extend Element with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RawElement with Eq::{equal, not_equal}

///|
pub extend RawElement with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Attribute with Eq::{equal, not_equal}

///|
pub extend Attribute with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Template with Eq::{equal, not_equal}

///|
pub extend Template with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplateFile with Eq::{equal, not_equal}

///|
pub extend TemplateFile with @moonbitlang/core/debug.Debug::{to_repr}

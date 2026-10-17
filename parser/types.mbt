///|
/// A node inside a template body. Recursive through `Element` and `Call`.
pub(all) enum Node {
  /// `<!doctype ...>`, carrying what sits between the keyword and `>` — `html`
  /// for the usual one.
  DocType(String)
  /// `<!-- ... -->`, carrying what sits between the delimiters.
  HTMLComment(String)
  /// `@expr` or `@expr { ... }`.
  Call(Call)
  /// `if cond { ... }` with its `else if` chain and its `else`.
  If(IfExpression)
  /// `for head { ... }`, in either of the two forms MoonBit writes.
  For(ForExpression)
  /// `match subject { pattern => { ... } }`.
  Match(MatchExpression)
  /// `{{ code }}`, written into the generated function body as it stands.
  GoCode(String)
  Element(Element)
  RawElement(RawElement)
  Text(String)
  StringExpression(String)
  /// `{ children... }`, where the component that was called renders what its
  /// caller handed it.
  ChildrenExpression
} derive(Debug, Eq)

///|
/// A component call. `expression` is the source spelling of what follows the
/// `@` marker, so `@@ui.Card(title)` keeps the package reference's own `@` while
/// `@Card(title)` does not. Empty `children` means the call stands alone: a
/// block that holds nothing but whitespace leaves nothing behind either.
pub(all) struct Call {
  expression : String
  children : Array[Node]
} derive(Debug, Eq)

///|
/// `if cond { ... } else if cond { ... } else { ... }`.
///
/// `condition` is the source text between the keyword and the block, copied
/// through as it stands, indentation and all: what an `if` may hold is what
/// MoonBit accepts, so the compiler is the one that checks it. An `else` that
/// holds nothing is no else branch at all, which is what an empty `else_` says —
/// templ drops the branch for the same reason.
pub(all) struct IfExpression {
  condition : String
  then : Array[Node]
  else_ifs : Array[ElseIf]
  else_ : Array[Node]
} derive(Debug, Eq)

///|
/// One `else if cond { ... }` of an `if`.
pub(all) struct ElseIf {
  condition : String
  then : Array[Node]
} derive(Debug, Eq)

///|
/// `for head { ... }`, in either of the two forms MoonBit writes: the C-style
/// `for i = 0; i < n; i = i + 1`, and `for v in items` — templ's range form,
/// which its own syntax would spell `for i, v := range items`. Both are what the
/// generated file holds, so an index may stand beside the value, and the head is
/// copied through as it stands for the compiler to check.
pub(all) struct ForExpression {
  expression : String
  children : Array[Node]
} derive(Debug, Eq)

///|
/// `match subject { pattern => { ... } }`, templ's `switch` written the way
/// MoonBit writes it: templ's `case x:` becomes an arm `x => {`, and its
/// `default:` becomes `_ => {`. The arm body is a block of its own, so a branch
/// holds a template's nodes rather than an expression — which is what lets a
/// pattern destructure, as in `Some(v) => { ... }`.
///
/// `subject` and every `pattern` are the source text between the markers, copied
/// through as they stand for the compiler to check.
pub(all) struct MatchExpression {
  subject : String
  arms : Array[MatchArm]
} derive(Debug, Eq)

///|
/// One `pattern => { ... }` of a `match`.
pub(all) struct MatchArm {
  pattern : String
  children : Array[Node]
} derive(Debug, Eq)

///|
pub(all) struct Element {
  name : String
  attrs : Array[Attribute]
  children : Array[Node]
  self_closing : Bool
  /// The attributes were laid out on lines of their own in the source, which is
  /// where the formatter puts them too.
  indent_attrs : Bool
  /// The element's tags and its children were on different lines in the source,
  /// which is where the formatter puts the children too. False keeps an element
  /// whose children share its line — `Hello, { name }!` — on one line, so that
  /// formatting never turns a space into a line break or the other way round.
  indent_children : Bool
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
  /// `name={ expr }`. `value` keeps the source spelling of the expression.
  Expression(name~ : String, value~ : String)
  /// `{ attrs... }`, where the whole attribute list comes from a value the
  /// template computes. `value` is the expression the `...` spreads, keeping its
  /// source spelling; the `...` is the syntax, not part of the expression.
  Spread(value~ : String)
  Bool(name~ : String)
  /// `name?={ expr }`: the attribute is written only when the expression is
  /// true. `value` keeps the source spelling of the expression, which is the
  /// whole of what the attribute says.
  BoolExpression(name~ : String, value~ : String)
  /// `if expr { attrs } else { attrs }`: which attributes the tag carries is
  /// decided at render time. `condition` keeps the source spelling of the
  /// expression, and `else_` is empty when the block has no else.
  Conditional(
    condition~ : String,
    then~ : Array[Attribute],
    else_~ : Array[Attribute]
  )
} derive(Debug, Eq)

///|
/// A `templ Name(params) { ... }` block. `params` keeps the source spelling of
/// the parameter list, e.g. `name : String`, and is copied verbatim into the
/// generated function header. `receiver` holds the `templ (self : T) Name()`
/// form the same way, and is empty for a plain function.
///
/// `start` and `end` are the UTF-16 offsets of the `templ` keyword and of the
/// character after the block's closing brace. They let a tool that rewrites the
/// blocks — the formatter — keep the file's other bytes, comments included, as
/// they were.
pub(all) struct Template {
  name : String
  receiver : String
  params : String
  nodes : Array[Node]
  start : Int32
  end : Int32
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
pub extend Call with Eq::{equal, not_equal}

///|
pub extend Call with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend IfExpression with Eq::{equal, not_equal}

///|
pub extend IfExpression with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ElseIf with Eq::{equal, not_equal}

///|
pub extend ElseIf with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ForExpression with Eq::{equal, not_equal}

///|
pub extend ForExpression with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MatchExpression with Eq::{equal, not_equal}

///|
pub extend MatchExpression with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MatchArm with Eq::{equal, not_equal}

///|
pub extend MatchArm with @moonbitlang/core/debug.Debug::{to_repr}

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

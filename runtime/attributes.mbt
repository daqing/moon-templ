///|
/// A name and a value together, templ's `templ.KeyValue`. A spread attribute and
/// a CSS class both pair a name with a flag that says whether it applies, which
/// is what templ's `templ.KV` builds.
pub(all) struct KV[K, V] {
  key : K
  value : V
}

///|
pub fn[K, V] kv(key : K, value : V) -> KV[K, V] {
  { key, value, }
}

///|
/// The value of one attribute in a `{ attrs... }` spread.
///
/// templ carries these in a `map[string]any` and switches on the dynamic type
/// while rendering. MoonBit has no such type, so the cases templ's switch held
/// are the variants here.
pub(all) enum AttributeValue {
  /// `name="value"`, with the value escaped.
  Value(String)
  /// The bare name when `true`, nothing at all when `false`. templ's bool
  /// pointer and its `func() bool` both land here: either one only decides
  /// whether the name stands alone.
  Flag(Bool)
  /// `name="value"` when the flag holds, nothing at all when it does not —
  /// templ's `templ.KV("lorem", true)`, which renders `text="lorem"` when the
  /// attribute is named `text`.
  Conditional(KV[String, Bool])
}

///|
/// A set of spread attributes, which is what `{ attrs... }` hands to
/// `render_attributes`.
///
/// templ models this as an interface over either a map or a slice. MoonBit does
/// not let a package implement a trait for a type it does not own, and `Map`
/// belongs to the core library, so those two shapes meet in one struct built by
/// one of two constructors rather than in two implementations of `Attributer`.
pub(all) struct Attributes {
  priv items : Array[KV[String, AttributeValue]]
}

///|
/// The attributes of a map, rendered in name order — templ's `templ.Attributes`.
/// Which order the map was written in does not reach the output: a map has none
/// of its own, and templ sorts one by key for the same reason.
///
/// templ sorts at render time; here the sort happens once, at construction,
/// because nothing can reach `items` afterwards.
pub fn Attributes::from_map(
  attributes : Map[String, AttributeValue],
) -> Attributes {
  let items : Array[KV[String, AttributeValue]] = []
  for name, value in attributes {
    items.push({ key: name, value, })
  }
  // templ sorts with Go's `<`, which compares byte by byte. MoonBit's own
  // `Compare for String` compares length first, so sorting by it would put `zz`
  // before `aaa`.
  items.sort_by(fn(a, b) { a.key[:].lexical_compare(b.key[:]) })
  { items, }
}

///|
/// The attributes in the order they were given — templ's
/// `templ.OrderedAttributes`.
pub fn Attributes::ordered(
  items : Array[KV[String, AttributeValue]],
) -> Attributes {
  { items, }
}

///|
/// What `{ attrs... }` can spread. The generated call takes anything that can
/// name its items, which is how a caller with attributes of its own can spread
/// them: `Map` is the core library's type, so a map is wrapped in `Attributes`
/// rather than made an `Attributer` itself.
pub(open) trait Attributer {
  fn items(Self) -> Array[KV[String, AttributeValue]]
}

///|
pub impl Attributer for Attributes with fn items(self) {
  self.items
}

///|
pub extend Attributes with Attributer::{items}

///|
/// `{ attrs... }` writes the whole of each attribute, separator included, so the
/// literal run of the start tag breaks around it. Names and values are escaped
/// here, the way templ's `RenderAttributes` escapes them.
pub fn[A : Attributer] render_attributes(w : &Logger, attributes : A) -> Unit {
  for item in attributes.items() {
    render_attribute(w, item.key, item.value)
  }
}

///|
fn render_attribute(w : &Logger, name : String, value : AttributeValue) -> Unit {
  match value {
    Value(v) => w.write_string(" " + escape(name) + "=\"" + escape(v) + "\"")
    Flag(true) => w.write_string(" " + escape(name))
    Flag(false) => ()
    Conditional(pair) =>
      if pair.value {
        w.write_string(" " + escape(name) + "=\"" + escape(pair.key) + "\"")
      }
  }
}

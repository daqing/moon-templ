///|
/// A CSS value the caller vouches for: templ's `templ.SafeCSS` and
/// `templ.SafeCSSProperty`. It is escaped for its place in the attribute but
/// never handed to the sanitizer.
pub(all) struct SafeCSS {
  priv value : String
}

///|
pub fn SafeCSS::new(value : String) -> SafeCSS {
  { value, }
}

///|
/// One piece of a `style` attribute. templ takes `...any` and switches on the
/// dynamic type, reflection included; MoonBit has neither `any` nor reflection,
/// so the shapes that switch handles by name are the variants here, and the
/// shapes it reached by reflection — a function, a slice of anything — are
/// written out by the caller as the variants they hold.
pub(all) enum StylePart {
  /// A whole style string, escaped the way a CSS string token is.
  Text(String)
  /// A whole style string the caller vouches for.
  Trusted(SafeCSS)
  /// `property: value`, both sanitized.
  Property(KV[String, String])
  /// `property: value` whose value the caller vouches for; the name is still
  /// checked.
  TrustedProperty(KV[String, SafeCSS])
  /// templ's `templ.KV("property: value", on)`: the key is a whole declaration
  /// rather than a name, and it is written only while the flag holds.
  Toggle(KV[String, Bool])
  /// The same, with a declaration the caller vouches for.
  TrustedToggle(KV[SafeCSS, Bool])
}

///|
/// A list of pieces: what `style={ ... }` renders, and the MoonBit spelling of
/// templ's `SanitizeStyleAttributeValues(values ...any)`.
pub(all) struct Style {
  priv parts : Array[StylePart]
}

///|
pub fn Style::new(parts : Array[StylePart]) -> Style {
  { parts, }
}

///|
/// The declarations of a map, rendered in property-name order — templ's
/// `map[string]string`, which it sorts for the same reason, a map having no
/// order of its own.
pub fn Style::from_map(properties : Map[String, String]) -> Style {
  let items : Array[KV[String, String]] = []
  for name, value in properties {
    items.push({ key: name, value, })
  }
  items.sort_by(fn(a, b) { a.key[:].lexical_compare(b.key[:]) })
  Style::new(items.map(fn(item) { Property(item) }))
}

///|
/// The declarations of a map whose values the caller vouches for — templ's
/// `map[string]templ.SafeCSSProperty`.
pub fn Style::from_trusted_map(properties : Map[String, SafeCSS]) -> Style {
  let items : Array[KV[String, SafeCSS]] = []
  for name, value in properties {
    items.push({ key: name, value, })
  }
  items.sort_by(fn(a, b) { a.key[:].lexical_compare(b.key[:]) })
  Style::new(items.map(fn(item) { TrustedProperty(item) }))
}

///|
/// What a `style={ ... }` attribute may hold. templ switches on the value's
/// dynamic type; here the value says what it is by which implementation it
/// takes, and a plain `String` — the common case, and the one templ's own
/// golden opens with — is one of them.
///
/// The value a `Stylable` renders is the one `SanitizeStyleAttributeValues`
/// returns: each piece escaped for its place between the quotes. The attribute
/// escapes that whole result again, exactly as templ's generator does, which is
/// why a value holding an `&` comes out as `&amp;amp;` here as well.
pub(open) trait Stylable {
  fn sanitized(Self) -> String
}

///|
/// The value of a `style={ ... }` attribute, ready to be written between the
/// quotes of the attribute: the sanitized value, escaped once more.
pub fn[A : Stylable] sanitize_style_attribute_value(v : A) -> String {
  escape(v.sanitized())
}

///|
pub impl Stylable for String with fn sanitized(self) {
  process_string(self)
}

///|
pub impl Stylable for SafeCSS with fn sanitized(self) {
  process_safe_css(self)
}

///|
pub extend SafeCSS with Stylable::{sanitized}

///|
pub impl Stylable for Style with fn sanitized(self) {
  let buf = StringBuilder()
  for part in self.parts {
    write_style_part(buf, part)
  }
  buf.to_string()
}

///|
pub extend Style with Stylable::{sanitized}

///|
fn write_style_part(buf : StringBuilder, part : StylePart) -> Unit {
  match part {
    Text(text) => buf.write_string(process_string(text))
    Trusted(safe) => buf.write_string(process_safe_css(safe))
    Property(pair) =>
      buf.write_string(process_property(pair.key, Sanitized(pair.value)))
    TrustedProperty(pair) =>
      buf.write_string(process_property(pair.key, Trusted(pair.value)))
    Toggle(pair) => if pair.value { buf.write_string(process_string(pair.key)) }
    TrustedToggle(pair) =>
      if pair.value {
        buf.write_string(process_safe_css(pair.key))
      }
  }
}

///|
/// The sanitized form of a whole style string: `processString`, which escapes
/// the value as a CSS string token and ends it with a declaration's semicolon.
fn process_string(value : String) -> String {
  if value.is_empty() {
    return ""
  }
  let sanitized = trim_space(sanitize_style_value(value))
  escape(sanitized) + semicolon_after(sanitized)
}

///|
/// The same for a value the caller vouches for: `processSafeCSS`, which escapes
/// it without sanitizing it.
fn process_safe_css(value : SafeCSS) -> String {
  if value.value.is_empty() {
    return ""
  }
  escape(value.value) + semicolon_after(value.value)
}

///|
fn semicolon_after(value : String) -> String {
  if value.has_suffix(";") {
    ""
  } else {
    ";"
  }
}

///|
/// One `property: value` declaration, which is what both of templ's key-value
/// shapes and both of its maps end up as.
fn process_property(name : String, value : PropertyValue) -> String {
  let (name, value) = match value {
    Sanitized(value) => sanitize_css(name, value)
    Trusted(value) => sanitize_css_name(name, value.value)
  }
  escape(name) + ":" + escape(value) + ";"
}

///|
/// Which side of a declaration the sanitizer is still owed: the value, or a name
/// plus a value the caller vouches for.
priv enum PropertyValue {
  Sanitized(String)
  Trusted(SafeCSS)
}

///|
/// `sanitizeRegular`'s verdict on a property value: one templ knows nothing
/// about is safe while every rune of it is one a value may hold, and a `*` or a
/// `/` — the halves of a comment — only while the next rune is safe too.
fn sanitize_regular(value : String) -> String {
  let chars = value.to_array()
  let mut i = 0
  while i < chars.length() {
    let c = chars[i]
    if is_safe_regular(c) {
      i = i + 1
      continue
    }
    if (c == '*' || c == '/') &&
      (i + 1 == chars.length() || is_safe_regular(chars[i + 1])) {
      i = i + 1
      continue
    }
    return INNOCUOUS_VALUE
  }
  value
}

///|
/// The runes `[0-9a-zA-Z+-.!#%_ \t]` holds. The `+-.` of that class is a range
/// rather than three runes, so the comma is in it — a property value may hold
/// one, whatever the comment beside the pattern in templ's source says.
fn is_safe_regular(c : Char) -> Bool {
  match c {
    '0'..<='9' | 'a'..<='z' | 'A'..<='Z' => true
    '+' | ',' | '-' | '.' | '!' | '#' | '%' | '_' | ' ' | '\t' => true
    _ => false
  }
}

///|
/// `sanitizeEnum`'s verdict: a value an enumerated property may hold is letters
/// and dashes.
fn sanitize_enum(value : String) -> String {
  for c in value {
    match c {
      'a'..<='z' | 'A'..<='Z' | '-' => ()
      _ => return INNOCUOUS_VALUE
    }
  }
  value
}

///|
/// `sanitizeFontFamily`'s verdict: a list of family names, each either quoted or
/// a generic name.
fn sanitize_font_family(value : String) -> String {
  for part in value.split(",") {
    let part = trim_space(part.to_owned())
    if part.has_prefix("\"") {
      if !part.has_suffix("\"") {
        return INNOCUOUS_VALUE
      }
      continue
    }
    if !is_generic_font_family(part) {
      return INNOCUOUS_VALUE
    }
  }
  value
}

///|
/// `^[a-zA-Z][- a-zA-Z]+$`: a generic family name, which is at least two runes
/// long because the pattern is.
fn is_generic_font_family(value : String) -> Bool {
  let chars = value.to_array()
  if chars.length() < 2 {
    return false
  }
  match chars[0] {
    'a'..<='z' | 'A'..<='Z' => ()
    _ => return false
  }
  for c in chars[1:] {
    match c {
      'a'..<='z' | 'A'..<='Z' | '-' | ' ' => ()
      _ => return false
    }
  }
  true
}

///|
/// `sanitizeBackgroundImage`'s verdict: a list of `url(...)`s, each of a URL
/// that may be followed.
fn sanitize_background_image(value : String) -> String {
  if value.contains("<") || value.contains(">") {
    return INNOCUOUS_VALUE
  }
  for part in value.split(",") {
    let part = trim_space(part.to_owned())
    match unwrap_url(part) {
      Some(url) => if !url_is_safe(url) { return INNOCUOUS_VALUE }
      None => return INNOCUOUS_VALUE
    }
  }
  value
}

///|
/// The URL inside a `url("...")`, `url('...')` or `url(...)`, or nothing when
/// the value is not one of those three.
fn unwrap_url(value : String) -> String? {
  let prefixes : Array[String] = ["url(\"", "url('", "url("]
  let suffixes : Array[String] = ["\")", "')", ")"]
  for i = 0; i < prefixes.length(); i = i + 1 {
    let prefix = prefixes[i]
    let suffix = suffixes[i]
    if value.has_prefix(prefix) && value.has_suffix(suffix) {
      let start = prefix.length()
      let end = value.length() - suffix.length()
      if start <= end {
        return Some(value[start:end].to_owned())
      }
    }
  }
  None
}

///|
/// Whether a URL inside `url(...)` may be followed: templ takes anything
/// relative, and a URL that names a scheme only when the scheme is one of the
/// three it knows.
///
/// This is templ's `urlIsSafe`, which asks `url.Parse` and then looks at the
/// scheme. Go refuses a URL it cannot parse, which is why the three checks above
/// the scheme are here: a control rune, a `%` that does not begin an escape, and
/// — for a URL that names no scheme and is not rooted — a `:` in its first path
/// segment, which is how a relative URL is told apart from a misspelled scheme.
fn url_is_safe(url : String) -> Bool {
  for c in url {
    if c <= '\u{1f}' || c == '\u{7f}' {
      return false
    }
  }
  if has_bad_escape(url) {
    return false
  }
  match scheme_of(url) {
    Some(scheme) =>
      scheme.to_lower() == "http" ||
      scheme.to_lower() == "https" ||
      scheme.to_lower() == "mailto"
    None =>
      if url.has_prefix(":") {
        false
      } else if url.has_prefix("/") {
        true
      } else {
        !first_segment(url).contains(":")
      }
  }
}

///|
/// Whether a `%` in the URL fails to begin an escape, which is what Go's
/// `EscapeError` reports.
fn has_bad_escape(url : String) -> Bool {
  let chars = url.to_array()
  let mut i = 0
  while i < chars.length() {
    if chars[i] == '%' {
      if i + 2 >= chars.length() ||
        !is_hex_digit(chars[i + 1]) ||
        !is_hex_digit(chars[i + 2]) {
        return true
      }
      i = i + 3
    } else {
      i = i + 1
    }
  }
  false
}

///|
fn is_hex_digit(c : Char) -> Bool {
  match c {
    '0'..<='9' | 'a'..<='f' | 'A'..<='F' => true
    _ => false
  }
}

///|
/// The text before the URL's first `/`, which is the segment Go checks for a
/// colon.
fn first_segment(url : String) -> String {
  match url.find("/") {
    Some(index) => url[:index].to_owned()
    None => url
  }
}

///|
/// The scheme a URL names, or nothing when it is relative. A scheme is the text
/// before the first `:` where that comes before any `/`, `?` or `#`, and it has
/// the shape `[a-zA-Z][a-zA-Z0-9+.-]*`.
fn scheme_of(url : String) -> String? {
  let buf = StringBuilder()
  for c in url {
    match c {
      'a'..<='z' | 'A'..<='Z' | '0'..<='9' | '+' | '-' | '.' => {
        if buf.is_empty() && !is_letter(c) {
          return None
        }
        buf.write_char(c)
      }
      ':' => {
        let scheme = buf.to_string()
        if scheme.is_empty() {
          return None
        }
        return Some(scheme)
      }
      _ => return None
    }
  }
  None
}

///|
fn is_letter(c : Char) -> Bool {
  match c {
    'a'..<='z' | 'A'..<='Z' => true
    _ => false
  }
}

///|
/// The sanitizers a property's value is owed, by the property's name —
/// `SanitizeCSSValue`'s table, which knows three properties by name and lets
/// everything else through the one check.
fn sanitize_css_value(property : String, value : String) -> String {
  match property {
    "display" => sanitize_enum(value)
    "font-family" => sanitize_font_family(value)
    "background-image" => sanitize_background_image(value)
    _ => sanitize_regular(value)
  }
}

///|
/// templ's `safehtml.SanitizeCSS`: the property's name is checked and lowered,
/// and its value is sanitized as the property's kind of value.
fn sanitize_css(property : String, value : String) -> (String, String) {
  let property = sanitize_css_property(property)
  if property == INNOCUOUS_PROPERTY {
    return (INNOCUOUS_PROPERTY, INNOCUOUS_VALUE)
  }
  (property, sanitize_css_value(property, value))
}

///|
/// The same for a value the caller vouches for: the name is checked, the value
/// is not.
fn sanitize_css_name(property : String, value : String) -> (String, String) {
  let property = sanitize_css_property(property)
  if property == INNOCUOUS_PROPERTY {
    return (INNOCUOUS_PROPERTY, INNOCUOUS_VALUE)
  }
  (property, value)
}

///|
/// Whether a name may be a CSS property's: `^[-a-zA-Z]+$`, lowered. Anything
/// else is replaced rather than dropped, so the declaration still has a name and
/// the page still has an attribute.
fn sanitize_css_property(property : String) -> String {
  if property.is_empty() {
    return INNOCUOUS_PROPERTY
  }
  for c in property {
    match c {
      'a'..<='z' | 'A'..<='Z' | '-' => ()
      _ => return INNOCUOUS_PROPERTY
    }
  }
  property.to_lower()
}

///|
/// The name a declaration with an unusable property gets, and the value one with
/// an unusable value gets. Both are templ's, and both are meant to be noticed.
const INNOCUOUS_PROPERTY : String = "zTemplUnsafeCSSPropertyName"

///|
const INNOCUOUS_VALUE : String = "zTemplUnsafeCSSPropertyValue"

///|
/// `safehtml.SanitizeStyleValue`: a style string escaped so that it may sit
/// between the quotes of an attribute, which is what keeps a `</style>` inside
/// one from ending the element it is written in.
///
/// A rune a string token may not hold is written as the CSS escape `\` and six
/// hex digits, and a null is replaced rather than escaped, both as templ does.
fn sanitize_style_value(value : String) -> String {
  let buf = StringBuilder()
  for c in value {
    match c {
      '\u{0}' => buf.write_string("\u{fffd}")
      '<' | '"' | '\\' => write_css_escape(buf, c)
      '\u{1}'..<='\u{1f}' | '\u{7f}'..<='\u{9f}' | '\u{2028}' | '\u{2029}' =>
        write_css_escape(buf, c)
      _ => buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
fn write_css_escape(buf : StringBuilder, c : Char) -> Unit {
  let digits : Array[Char] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  ]
  buf.write_char('\\')
  let mut shift = 20
  while shift >= 0 {
    buf.write_char(digits[(c.to_int() >> shift) & 0xF])
    shift = shift - 4
  }
}

///|
/// Go's `unicode.IsSpace`, which is what `strings.TrimSpace` trims and what
/// `strings.Fields` splits on.
fn trim_space(value : String) -> String {
  let chars = value.to_array()
  let mut start = 0
  let mut end = chars.length()
  while start < end && is_space(chars[start]) {
    start = start + 1
  }
  while end > start && is_space(chars[end - 1]) {
    end = end - 1
  }
  let buf = StringBuilder()
  for i = start; i < end; i = i + 1 {
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
fn is_space(c : Char) -> Bool {
  c == ' ' ||
  c == '\t' ||
  c == '\n' ||
  c == '\r' ||
  c == '\u{0b}' ||
  c == '\u{0c}' ||
  c == '\u{85}' ||
  c == '\u{a0}'
}

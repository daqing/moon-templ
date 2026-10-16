///|
/// The value of a `name={ expr }` attribute, escaped for its place inside a
/// double-quoted attribute value. templ's `ResolveAttributeValue` does the same
/// for every value type that is not a script or a URL, and those two get their
/// own handling later.
pub fn[T : Show] resolve_attribute_value(v : T) -> String {
  escape(v.to_string())
}

///|
fn[A : @runtime.Attributer] render_spread(attributes : A) -> String {
  let c = @runtime.component(fn(_ctx, w) {
    @runtime.render_attributes(w, attributes)
  })
  c.to_string()
}

///|
fn map_attributes(
  attributes : Map[String, @runtime.AttributeValue],
) -> @runtime.Attributes {
  @runtime.Attributes::from_map(attributes)
}

///|
test "a map spread renders its items in name order" {
  let attrs = map_attributes({
    "id": @runtime.Value("test"),
    "class": @runtime.Value("a b"),
    "hidden": @runtime.Flag(true),
  })
  assert_eq(render_spread(attrs), " class=\"a b\" hidden id=\"test\"")
}

///|
/// The map is written in a different order from the one above and holds the same
/// attributes, so it renders the same way: a map has no order of its own.
test "a map spread renders alike whatever order it was written in" {
  let attrs = map_attributes({
    "hidden": @runtime.Flag(true),
    "class": @runtime.Value("a b"),
    "id": @runtime.Value("test"),
  })
  assert_eq(render_spread(attrs), " class=\"a b\" hidden id=\"test\"")
}

///|
test "an ordered spread renders in the order it was given" {
  let attrs = @runtime.Attributes::ordered([
    @runtime.kv("id", @runtime.Value("test")),
    @runtime.kv("hidden", @runtime.Flag(true)),
    @runtime.kv("class", @runtime.Value("a b")),
  ])
  assert_eq(render_spread(attrs), " id=\"test\" hidden class=\"a b\"")
}

///|
test "a false flag leaves the attribute out" {
  let attrs = @runtime.Attributes::ordered([
    @runtime.kv("id", @runtime.Value("test")),
    @runtime.kv("hidden", @runtime.Flag(false)),
  ])
  assert_eq(render_spread(attrs), " id=\"test\"")
}

///|
test "a conditional attribute follows its flag" {
  let attrs = @runtime.Attributes::ordered([
    @runtime.kv("text", @runtime.Conditional(@runtime.kv("lorem", true))),
    @runtime.kv("title", @runtime.Conditional(@runtime.kv("gone", false))),
  ])
  assert_eq(render_spread(attrs), " text=\"lorem\"")
}

///|
test "names and values are escaped" {
  let attrs = @runtime.Attributes::ordered([
    @runtime.kv("title", @runtime.Value("a&b<c>d\"e'f")),
  ])
  assert_eq(render_spread(attrs), " title=\"a&amp;b&lt;c&gt;d&#34;e&#39;f\"")
}

///|
test "an empty spread writes nothing" {
  assert_eq(render_spread(map_attributes({})), "")
  assert_eq(render_spread(@runtime.Attributes::ordered([])), "")
}

///|
/// The map is sorted by name rather than by the length-first order MoonBit's own
/// `Compare for String` gives, so `zz` comes after `aaa` instead of before it.
test "a map spread sorts by name, not by length" {
  let attrs = map_attributes({
    "zz": @runtime.Flag(true),
    "aaa": @runtime.Flag(true),
  })
  assert_eq(render_spread(attrs), " aaa zz")
}

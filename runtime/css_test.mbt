///|
test "constants and flags mix into one list" {
  let classes = @runtime.CSSClasses::new([
    @runtime.Name("a"),
    @runtime.Toggle(@runtime.kv("b", true)),
    @runtime.Name("c"),
    @runtime.Toggle(@runtime.kv("d", false)),
  ])
  assert_eq(classes.to_string(), "a b c")
}

///|
/// templ's own case for this, from `TestClassesFunction`: the flag on `c` comes
/// after `c` itself was named, and it still turns the name off.
test "a flag written later turns an earlier name off" {
  let classes = @runtime.CSSClasses::new([
    @runtime.Name("a"),
    @runtime.Toggle(@runtime.kv("b", true)),
    @runtime.Name("c"),
    @runtime.Toggle(@runtime.kv("c", false)),
    @runtime.Toggle(@runtime.kv("d", true)),
    @runtime.Toggle(@runtime.kv("e", false)),
  ])
  assert_eq(classes.to_string(), "a b d")
}

///|
/// The other way round: the name is written after the flag that turned it off,
/// and a plain name is a flag that says on, so `a` is back.
test "a name written after its flag comes back" {
  let classes = @runtime.CSSClasses::new([
    @runtime.Toggle(@runtime.kv("a", false)),
    @runtime.Name("a"),
  ])
  assert_eq(classes.to_string(), "a")
}

///|
test "a name that is named twice renders once" {
  let classes = @runtime.CSSClasses::new([
    @runtime.Name("a"),
    @runtime.Name("b"),
    @runtime.Name("a"),
  ])
  assert_eq(classes.to_string(), "a b")
}

///|
/// The list keeps the order it was written in; unlike the spread attributes map,
/// nothing here is sorted.
test "the list keeps its order" {
  let classes = @runtime.CSSClasses::new([
    @runtime.Name("zz"),
    @runtime.Name("aaa"),
  ])
  assert_eq(classes.to_string(), "zz aaa")
}

///|
test "an empty list renders nothing" {
  assert_eq(@runtime.CSSClasses::new([]).to_string(), "")
  let all_off = @runtime.CSSClasses::new([
    @runtime.Toggle(@runtime.kv("a", false)),
  ])
  assert_eq(all_off.to_string(), "")
}

///|
/// The names are written as they stand: escaping belongs to the attribute value
/// they end up in, which is where templ escapes them too.
test "names are not escaped here" {
  let classes = @runtime.CSSClasses::new([@runtime.Name("a </style>")])
  assert_eq(classes.to_string(), "a </style>")
}

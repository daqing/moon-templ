///|
/// templ's `generator/test-if` golden, whose `expected.html` is `True`: an `if`
/// renders one of two string expressions depending on a method call.
///
/// The golden only reaches the branch its own data takes — `data.IsTrue` returns
/// a constant `true` — so the `else` half is asserted here as well. Nothing
/// stands between the branches and the output: templ's generator writes no
/// whitespace of its own for a branch, and neither does this one.
test "an if renders the branch its condition picks" {
  assert_eq(render(Data::new(true)).to_string(), "True")
  assert_eq(render(Data::new(false)).to_string(), "False")
}

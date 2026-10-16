///|
test "the example renders exactly this HTML" {
  assert_eq(
    hello("world").to_string(),
    "<div class=\"greeting\">Hello, world!</div>",
  )
}

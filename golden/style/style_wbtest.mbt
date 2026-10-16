///|
/// templ's `generator/test-style-attribute` golden, whose `expected.html` is two
/// buttons styled `background-color: blue; color: red` and `background-color:
/// red`. The golden compares by HTML diff, so its file is written the way a
/// reader would write the styles; what it renders is below, and it is what this
/// test asserts.
///
/// The golden writes both buttons through one template that takes `any` and
/// calls it seven times, once per kind of value — a string, a `templ.SafeCSS`,
/// four shapes of map and key-value list, and a function's result. MoonBit has
/// no `any`, so a value says what it is by which template it is handed to; the
/// seven kinds are the seven calls below, and all seven render the same thing.
///
/// The second button's `background-color: red` keeps the space the function
/// wrote and gains the sanitizer's semicolon, which is what templ renders too.
test "a style attribute renders its sanitized value" {
  let buttons = "<button style=\"background-color:blue;color:red;\">Click me</button> " +
    "<button style=\"background-color: red;\">Click me</button>"
  let one_button = "<button style=\"background-color:blue;color:red;\">Click me</button>"
  assert_eq(
    button("background-color:blue;color:red", "Click me").to_string(),
    buttons,
  )
  assert_eq(
    button_trusted(
      @rt.SafeCSS::new("background-color:blue;color:red;"),
      "Click me",
    ).to_string(),
    one_button,
  )
  assert_eq(
    button_with(
      @rt.Style::from_map({ "color": "red", "background-color": "blue" }),
      "Click me",
    ).to_string(),
    one_button,
  )
  assert_eq(
    button_with(
      @rt.Style::from_trusted_map({
        "color": @rt.SafeCSS::new("red"),
        "background-color": @rt.SafeCSS::new("blue"),
      }),
      "Click me",
    ).to_string(),
    one_button,
  )
  assert_eq(
    button_with(
      @rt.Style::new([
        @rt.Property(@rt.kv("background-color", "blue")),
        @rt.Property(@rt.kv("color", "red")),
      ]),
      "Click me",
    ).to_string(),
    one_button,
  )
  assert_eq(
    button_with(
      @rt.Style::new([
        @rt.Toggle(@rt.kv("background-color:blue", true)),
        @rt.Toggle(@rt.kv("color:red", true)),
        @rt.Toggle(@rt.kv("color:blue", false)),
      ]),
      "Click me",
    ).to_string(),
    one_button,
  )
  assert_eq(
    button_with(
      @rt.Style::new([
        @rt.TrustedToggle(
          @rt.kv(@rt.SafeCSS::new("background-color:blue"), true),
        ),
        @rt.TrustedToggle(@rt.kv(@rt.SafeCSS::new("color:red"), true)),
        @rt.TrustedToggle(@rt.kv(@rt.SafeCSS::new("color:blue"), false)),
      ]),
      "Click me",
    ).to_string(),
    one_button,
  )
}

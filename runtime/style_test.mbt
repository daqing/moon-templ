///|
/// A whole style string is escaped as a CSS string token rather than parsed, so
/// the value is written the way it was given, less the whitespace around it, and
/// ended with the semicolon a declaration carries.
test "a style string is escaped and ended with a semicolon" {
  assert_eq(
    @runtime.sanitize_style_attribute_value("  color:red  "),
    "color:red;",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value("color:red;font-family:sans-serif"),
    "color:red;font-family:sans-serif;",
  )
  assert_eq(@runtime.sanitize_style_attribute_value("color:red;"), "color:red;")
}

///|
/// An empty string is nothing at all rather than a lone semicolon, but a string
/// of spaces is not empty and does get one.
test "an empty style string renders nothing" {
  assert_eq(@runtime.sanitize_style_attribute_value(""), "")
  assert_eq(@runtime.sanitize_style_attribute_value("   "), ";")
}

///|
/// The point of escaping the string: a `</style>` inside a style attribute must
/// not be able to end the element it is written in. templ escapes the `<` as a
/// CSS escape rather than the HTML entity `&lt;`, so that a reader of the CSS
/// sees an ordinary rune.
test "a style string cannot end the element it is written in" {
  assert_eq(
    @runtime.sanitize_style_attribute_value("</style>"),
    "\\00003C/style&amp;gt;;",
  )
  assert_eq(@runtime.sanitize_style_attribute_value("a\"b"), "a\\000022b;")
  assert_eq(@runtime.sanitize_style_attribute_value("a\\b"), "a\\00005Cb;")
}

///|
/// A null is replaced rather than escaped: templ writes the replacement
/// character, since a user agent that mishandles a null inside CSS is exactly
/// what the escape would be guarding against.
test "a null in a style string is replaced, not escaped" {
  assert_eq(@runtime.sanitize_style_attribute_value("\u{0}"), "\u{fffd};")
  assert_eq(@runtime.sanitize_style_attribute_value("a\u{1f}b"), "a\\00001Fb;")
  assert_eq(
    @runtime.sanitize_style_attribute_value("a\u{2028}b"),
    "a\\002028b;",
  )
}

///|
/// The attribute escapes what the sanitizer left, so a value that survives the
/// sanitizer with an `&`, a `'` or a `>` in it — the three the CSS escape does
/// not take — comes out escaped twice. That is templ's own doing: its runtime
/// escapes the pieces of the value and its generated code escapes the result.
test "the attribute escapes what the sanitizer escaped" {
  assert_eq(@runtime.sanitize_style_attribute_value("a&b"), "a&amp;amp;b;")
  assert_eq(@runtime.sanitize_style_attribute_value("'"), "&amp;#39;;")
  assert_eq(@runtime.sanitize_style_attribute_value("a>b"), "a&amp;gt;b;")
}

///|
/// A value the caller vouches for is escaped for its place in the attribute and
/// otherwise left alone: it is not trimmed, not escaped as a string token, and
/// not parsed as a declaration.
test "a trusted value is escaped but not sanitized" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(@runtime.SafeCSS::new("  a  ")),
    "  a  ;",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value(@runtime.SafeCSS::new("</style>")),
    "&amp;lt;/style&amp;gt;;",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value(@runtime.SafeCSS::new("")),
    "",
  )
}

///|
/// A property written as a name and a value is the one shape that is parsed:
/// the name is checked and lowered, and the value is sanitized as the kind of
/// value that property takes.
test "a property is checked by name and sanitized by value" {
  let color = fn(value) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([@runtime.Property(@runtime.kv("color", value))]),
    )
  }
  assert_eq(color("red"), "color:red;")
  assert_eq(color("12px"), "color:12px;")
  assert_eq(color("1px 2px"), "color:1px 2px;")
}

///|
/// The name is lowered before it is written, so a property spelled in capitals
/// renders as the property CSS knows.
test "a property name is lowered" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([@runtime.Property(@runtime.kv("COLOR", "red"))]),
    ),
    "color:red;",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.Property(@runtime.kv("-Webkit-Box-Shadow", "0 0 1px red")),
      ]),
    ),
    "-webkit-box-shadow:0 0 1px red;",
  )
}

///|
/// A name that could not be a property's is replaced rather than dropped, and
/// the value is replaced with it: templ writes both, so the declaration is still
/// there to be noticed in the output.
test "a property name that is not one is replaced" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([@runtime.Property(@runtime.kv("wid th", "1px"))]),
    ),
    "zTemplUnsafeCSSPropertyName:zTemplUnsafeCSSPropertyValue;",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([@runtime.Property(@runtime.kv("", "1px"))]),
    ),
    "zTemplUnsafeCSSPropertyName:zTemplUnsafeCSSPropertyValue;",
  )
}

///|
/// A value may not call anything or hold a comment, since either could put
/// something else in the declaration's place. A `*` or a `/` is allowed when it
/// is not next to another one, which is templ's `sanitizeRegular` written out:
/// it lets the rune through only when a comment cannot be spelled with it.
test "a property value may not call anything or hold a comment" {
  let color = fn(value) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([@runtime.Property(@runtime.kv("color", value))]),
    )
  }
  let replaced = "color:zTemplUnsafeCSSPropertyValue;"
  assert_eq(color("expression(alert(1))"), replaced)
  assert_eq(color("a/*b*/c"), replaced)
  assert_eq(color("a//b"), replaced)
  assert_eq(color("**"), replaced)
  assert_eq(color("r&d"), replaced)
  assert_eq(color("'a'"), replaced)
  assert_eq(color("a*"), "color:a*;")
  assert_eq(color("*a"), "color:*a;")
  assert_eq(color("*"), "color:*;")
}

///|
/// The class of runes templ calls safe is `[0-9a-zA-Z+-.!#%_ \t]`, in which
/// `+-.` is a range and not three runes — so the comma is in it and a value may
/// hold one, whatever the comment beside the pattern says.
test "a comma is a rune a property value may hold" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.Property(@runtime.kv("font-family", "sans-serif, monospace")),
      ]),
    ),
    "font-family:sans-serif, monospace;",
  )
}

///|
/// Three properties are sanitized as the kind of value they take rather than by
/// the runes a value may hold: `display` is an enumerated value, a font family
/// is a list of names, and a background image is a list of URLs.
test "three properties have a value shape of their own" {
  let style = fn(name, value) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([@runtime.Property(@runtime.kv(name, value))]),
    )
  }
  assert_eq(style("display", "inline-block"), "display:inline-block;")
  assert_eq(style("display", "block1"), "display:zTemplUnsafeCSSPropertyValue;")
  assert_eq(style("font-family", "sans-serif"), "font-family:sans-serif;")
  assert_eq(
    style("font-family", "\"My Font\",sans-serif"),
    "font-family:&amp;#34;My Font&amp;#34;,sans-serif;",
  )
  assert_eq(
    style("font-family", "\"My Font"),
    "font-family:zTemplUnsafeCSSPropertyValue;",
  )
  assert_eq(
    style("font-family", "Arial, 'My Font'"),
    "font-family:zTemplUnsafeCSSPropertyValue;",
  )
}

///|
/// A background image is a list of `url(...)`s and each URL has to be one that
/// may be followed: anything relative, and an absolute URL only over `http`,
/// `https` or `mailto`.
test "a background image is a list of urls that may be followed" {
  let image = fn(value) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.Property(@runtime.kv("background-image", value)),
      ]),
    )
  }
  let replaced = "background-image:zTemplUnsafeCSSPropertyValue;"
  assert_eq(
    image("url(https://example.com/a.png)"),
    "background-image:url(https://example.com/a.png);",
  )
  assert_eq(
    image("url(HTTPS://EXAMPLE.COM/a.png)"),
    "background-image:url(HTTPS://EXAMPLE.COM/a.png);",
  )
  assert_eq(image("url(/a.png)"), "background-image:url(/a.png);")
  assert_eq(
    image("url(//example.com/a.png)"),
    "background-image:url(//example.com/a.png);",
  )
  assert_eq(image("url(mailto:a@b.c)"), "background-image:url(mailto:a@b.c);")
  assert_eq(
    image("url(https://example.com/a.png), url(http://example.com/b.png)"),
    "background-image:url(https://example.com/a.png), url(http://example.com/b.png);",
  )
  assert_eq(image("url(javascript:alert(1))"), replaced)
  assert_eq(image("url(ftp://example.com/a.png)"), replaced)
  assert_eq(image("url(https://example.com/<a>)"), replaced)
  assert_eq(image("url(\"https://example.com/a.png)"), replaced)
  assert_eq(image("IMAGE"), replaced)
}

///|
/// Go parses the URL before it looks at the scheme, so a URL it refuses is not
/// safe however relative it looks. The three it refuses are a control rune, a
/// `%` that does not begin an escape, and a colon in the first segment of a URL
/// that names no scheme and is not rooted.
test "a url that cannot be parsed is not safe" {
  let image = fn(value) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.Property(@runtime.kv("background-image", value)),
      ]),
    )
  }
  let replaced = "background-image:zTemplUnsafeCSSPropertyValue;"
  assert_eq(image("url(%zz)"), replaced)
  assert_eq(image("url(a:b)"), replaced)
  assert_eq(image("url(:x)"), replaced)
  assert_eq(image("url(\"https://example.com/a.png)"), replaced)
  assert_eq(
    image("url(https://example.com/a%20b.png)"),
    "background-image:url(https://example.com/a%20b.png);",
  )
}

///|
/// A declaration written as a flag is a whole declaration rather than a name and
/// a value, so it is escaped as a string and written only while the flag holds.
test "a declaration behind a flag is written only while the flag holds" {
  let declaration = fn(on) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.Toggle(@runtime.kv("background-color:blue", on)),
      ]),
    )
  }
  assert_eq(declaration(true), "background-color:blue;")
  assert_eq(declaration(false), "")
}

///|
/// The same with a declaration the caller vouches for, which is templ's
/// `templ.KV(templ.SafeCSS(...), on)`.
test "a trusted declaration behind a flag" {
  let declaration = fn(on) {
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.TrustedToggle(
          @runtime.kv(@runtime.SafeCSS::new("</style>"), on),
        ),
      ]),
    )
  }
  assert_eq(declaration(true), "&amp;lt;/style&amp;gt;;")
  assert_eq(declaration(false), "")
}

///|
/// A declaration whose value the caller vouches for still has its name checked:
/// the name is the part that decides what the value means.
test "a trusted value does not excuse the property name" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.TrustedProperty(
          @runtime.kv("color", @runtime.SafeCSS::new("expression(alert(1))")),
        ),
      ]),
    ),
    "color:expression(alert(1));",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.TrustedProperty(
          @runtime.kv("wid th", @runtime.SafeCSS::new("red")),
        ),
      ]),
    ),
    "zTemplUnsafeCSSPropertyName:zTemplUnsafeCSSPropertyValue;",
  )
}

///|
/// The pieces of a list are written one after another in the order they were
/// given, which is what makes a style built from several expressions readable.
test "the pieces of a style are written in order" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::new([
        @runtime.Property(@runtime.kv("color", "red")),
        @runtime.Text("background-color:blue"),
        @runtime.Trusted(@runtime.SafeCSS::new("border:0")),
      ]),
    ),
    "color:red;background-color:blue;border:0;",
  )
}

///|
/// A map of declarations is written in property-name order, which is what templ
/// does with one: a map has no order of its own, so both sides sort by name.
test "a map of declarations is written in name order" {
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::from_map({ "color": "red", "background-color": "blue" }),
    ),
    "background-color:blue;color:red;",
  )
  assert_eq(
    @runtime.sanitize_style_attribute_value(
      @runtime.Style::from_trusted_map({
        "color": @runtime.SafeCSS::new("expression(x)"),
        "background-color": @runtime.SafeCSS::new("blue"),
      }),
    ),
    "background-color:blue;color:expression(x);",
  )
}

///|
// Generated from templ v0.3.1070's own generator: each line is the concatenation
// of the string literals templ emits for that template body. Regenerate rather
// than hand-editing.
test "differential: matches templ's whitespace output" {
  assert_eq(preview("<p>a</p>"), "<p>a</p>")
  assert_eq(preview("<p> a </p>"), "<p>a </p>")
  assert_eq(preview("<p>a </p>"), "<p>a </p>")
  assert_eq(preview("<p> a</p>"), "<p>a</p>")
  assert_eq(preview("<p>\na\n</p>"), "<p>a</p>")
  assert_eq(preview("<p>a\n</p>"), "<p>a</p>")
  assert_eq(preview("<p>\na</p>"), "<p>a</p>")
  assert_eq(preview("<p>\n\ta\n\t</p>"), "<p>a</p>")
  assert_eq(preview("<p>a\n\t</p>"), "<p>a</p>")
  assert_eq(preview("<p>\n\ta</p>"), "<p>a</p>")
  assert_eq(preview("<p>  a  </p>"), "<p>a  </p>")
  assert_eq(preview("<p>a  </p>"), "<p>a  </p>")
  assert_eq(preview("<p>  a</p>"), "<p>a</p>")
  assert_eq(preview("<p>\n\na\n\n</p>"), "<p>a</p>")
  assert_eq(preview("<p>a\n\n</p>"), "<p>a</p>")
  assert_eq(preview("<p>\n\na</p>"), "<p>a</p>")
  assert_eq(preview("<p> \n a \n </p>"), "<p>a </p>")
  assert_eq(preview("<p>a \n </p>"), "<p>a </p>")
  assert_eq(preview("<p> \n a</p>"), "<p>a</p>")
  assert_eq(preview("<p>\ta\t</p>"), "<p>a\t</p>")
  assert_eq(preview("<p>a\t</p>"), "<p>a\t</p>")
  assert_eq(preview("<p>\ta</p>"), "<p>a</p>")
  assert_eq(preview("<p>b c</p>"), "<p>b c</p>")
  assert_eq(preview("<p> b c </p>"), "<p>b c </p>")
  assert_eq(preview("<p>b c </p>"), "<p>b c </p>")
  assert_eq(preview("<p> b c</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\nb c\n</p>"), "<p>b c</p>")
  assert_eq(preview("<p>b c\n</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\nb c</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\n\tb c\n\t</p>"), "<p>b c</p>")
  assert_eq(preview("<p>b c\n\t</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\n\tb c</p>"), "<p>b c</p>")
  assert_eq(preview("<p>  b c  </p>"), "<p>b c  </p>")
  assert_eq(preview("<p>b c  </p>"), "<p>b c  </p>")
  assert_eq(preview("<p>  b c</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\n\nb c\n\n</p>"), "<p>b c</p>")
  assert_eq(preview("<p>b c\n\n</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\n\nb c</p>"), "<p>b c</p>")
  assert_eq(preview("<p> \n b c \n </p>"), "<p>b c </p>")
  assert_eq(preview("<p>b c \n </p>"), "<p>b c </p>")
  assert_eq(preview("<p> \n b c</p>"), "<p>b c</p>")
  assert_eq(preview("<p>\tb c\t</p>"), "<p>b c\t</p>")
  assert_eq(preview("<p>b c\t</p>"), "<p>b c\t</p>")
  assert_eq(preview("<p>\tb c</p>"), "<p>b c</p>")
  assert_eq(preview("<p>a   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p> a   b </p>"), "<p>a   b </p>")
  assert_eq(preview("<p>a   b </p>"), "<p>a   b </p>")
  assert_eq(preview("<p> a   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\na   b\n</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>a   b\n</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\na   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\n\ta   b\n\t</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>a   b\n\t</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\n\ta   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>  a   b  </p>"), "<p>a   b  </p>")
  assert_eq(preview("<p>a   b  </p>"), "<p>a   b  </p>")
  assert_eq(preview("<p>  a   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\n\na   b\n\n</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>a   b\n\n</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\n\na   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p> \n a   b \n </p>"), "<p>a   b </p>")
  assert_eq(preview("<p>a   b \n </p>"), "<p>a   b </p>")
  assert_eq(preview("<p> \n a   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>\ta   b\t</p>"), "<p>a   b\t</p>")
  assert_eq(preview("<p>a   b\t</p>"), "<p>a   b\t</p>")
  assert_eq(preview("<p>\ta   b</p>"), "<p>a   b</p>")
  assert_eq(preview("<p>{ x }</p>"), "<p>§</p>")
  assert_eq(preview("<p> { x } </p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x } </p>"), "<p>§</p>")
  assert_eq(preview("<p> { x }</p>"), "<p>§</p>")
  assert_eq(preview("<p>\n{ x }\n</p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x }\n</p>"), "<p>§</p>")
  assert_eq(preview("<p>\n{ x }</p>"), "<p>§</p>")
  assert_eq(preview("<p>\n\t{ x }\n\t</p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x }\n\t</p>"), "<p>§</p>")
  assert_eq(preview("<p>\n\t{ x }</p>"), "<p>§</p>")
  assert_eq(preview("<p>  { x }  </p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x }  </p>"), "<p>§</p>")
  assert_eq(preview("<p>  { x }</p>"), "<p>§</p>")
  assert_eq(preview("<p>\n\n{ x }\n\n</p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x }\n\n</p>"), "<p>§</p>")
  assert_eq(preview("<p>\n\n{ x }</p>"), "<p>§</p>")
  assert_eq(preview("<p> \n { x } \n </p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x } \n </p>"), "<p>§</p>")
  assert_eq(preview("<p> \n { x }</p>"), "<p>§</p>")
  assert_eq(preview("<p>\t{ x }\t</p>"), "<p>§</p>")
  assert_eq(preview("<p>{ x }\t</p>"), "<p>§</p>")
  assert_eq(preview("<p>\t{ x }</p>"), "<p>§</p>")
  assert_eq(preview("<p>x{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p> x{y}z </p>"), "<p>x§z </p>")
  assert_eq(preview("<p>x{y}z </p>"), "<p>x§z </p>")
  assert_eq(preview("<p> x{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\nx{y}z\n</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>x{y}z\n</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\nx{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\n\tx{y}z\n\t</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>x{y}z\n\t</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\n\tx{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>  x{y}z  </p>"), "<p>x§z  </p>")
  assert_eq(preview("<p>x{y}z  </p>"), "<p>x§z  </p>")
  assert_eq(preview("<p>  x{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\n\nx{y}z\n\n</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>x{y}z\n\n</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\n\nx{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p> \n x{y}z \n </p>"), "<p>x§z </p>")
  assert_eq(preview("<p>x{y}z \n </p>"), "<p>x§z </p>")
  assert_eq(preview("<p> \n x{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p>\tx{y}z\t</p>"), "<p>x§z\t</p>")
  assert_eq(preview("<p>x{y}z\t</p>"), "<p>x§z\t</p>")
  assert_eq(preview("<p>\tx{y}z</p>"), "<p>x§z</p>")
  assert_eq(preview("<p><b>a</b>\n\t<b>a</b></p>"), "<p><b>a</b> <b>a</b></p>")
  assert_eq(preview("<p><b>a</b> \n <b>a</b></p>"), "<p><b>a</b> <b>a</b></p>")
  assert_eq(preview("<p><b>a</b>\n<p>a</p></p>"), "<p><b>a</b><p>a</p></p>")
  assert_eq(preview("<p><b>a</b>\n\n<p>a</p></p>"), "<p><b>a</b><p>a</p></p>")
  assert_eq(
    preview("<p><b>a</b> <span>a</span></p>"),
    "<p><b>a</b> <span>a</span></p>",
  )
  assert_eq(
    preview("<p><b>a</b>  <span>a</span></p>"),
    "<p><b>a</b> <span>a</span></p>",
  )
  assert_eq(
    preview("<p><b>a</b>\t<span>a</span></p>"),
    "<p><b>a</b> <span>a</span></p>",
  )
  assert_eq(
    preview("<p><b>a</b>\n\t<div>a</div></p>"),
    "<p><b>a</b><div>a</div></p>",
  )
  assert_eq(
    preview("<p><b>a</b> \n <div>a</div></p>"),
    "<p><b>a</b><div>a</div></p>",
  )
  assert_eq(preview("<p><b>a</b>\n{ x }</p>"), "<p><b>a</b> §</p>")
  assert_eq(preview("<p><b>a</b>\n\n{ x }</p>"), "<p><b>a</b> §</p>")
  assert_eq(preview("<p><b>a</b> text</p>"), "<p><b>a</b> text</p>")
  assert_eq(preview("<p><b>a</b>  text</p>"), "<p><b>a</b> text</p>")
  assert_eq(preview("<p><b>a</b>\ttext</p>"), "<p><b>a</b> text</p>")
  assert_eq(preview("<p><p>a</p>\n\t<b>a</b></p>"), "<p><p>a</p><b>a</b></p>")
  assert_eq(preview("<p><p>a</p> \n <b>a</b></p>"), "<p><p>a</p><b>a</b></p>")
  assert_eq(preview("<p><p>a</p>\n<p>a</p></p>"), "<p><p>a</p><p>a</p></p>")
  assert_eq(preview("<p><p>a</p>\n\n<p>a</p></p>"), "<p><p>a</p><p>a</p></p>")
  assert_eq(
    preview("<p><p>a</p> <span>a</span></p>"),
    "<p><p>a</p><span>a</span></p>",
  )
  assert_eq(
    preview("<p><p>a</p>  <span>a</span></p>"),
    "<p><p>a</p><span>a</span></p>",
  )
  assert_eq(
    preview("<p><p>a</p>\t<span>a</span></p>"),
    "<p><p>a</p><span>a</span></p>",
  )
  assert_eq(
    preview("<p><p>a</p>\n\t<div>a</div></p>"),
    "<p><p>a</p><div>a</div></p>",
  )
  assert_eq(
    preview("<p><p>a</p> \n <div>a</div></p>"),
    "<p><p>a</p><div>a</div></p>",
  )
  assert_eq(preview("<p><p>a</p>\n{ x }</p>"), "<p><p>a</p>§</p>")
  assert_eq(preview("<p><p>a</p>\n\n{ x }</p>"), "<p><p>a</p>§</p>")
  assert_eq(preview("<p><p>a</p> text</p>"), "<p><p>a</p>text</p>")
  assert_eq(preview("<p><p>a</p>  text</p>"), "<p><p>a</p>text</p>")
  assert_eq(preview("<p><p>a</p>\ttext</p>"), "<p><p>a</p>text</p>")
  assert_eq(
    preview("<p><span>a</span>\n\t<b>a</b></p>"),
    "<p><span>a</span> <b>a</b></p>",
  )
  assert_eq(
    preview("<p><span>a</span> \n <b>a</b></p>"),
    "<p><span>a</span> <b>a</b></p>",
  )
  assert_eq(
    preview("<p><span>a</span>\n<p>a</p></p>"),
    "<p><span>a</span><p>a</p></p>",
  )
  assert_eq(
    preview("<p><span>a</span>\n\n<p>a</p></p>"),
    "<p><span>a</span><p>a</p></p>",
  )
  assert_eq(
    preview("<p><span>a</span> <span>a</span></p>"),
    "<p><span>a</span> <span>a</span></p>",
  )
  assert_eq(
    preview("<p><span>a</span>  <span>a</span></p>"),
    "<p><span>a</span> <span>a</span></p>",
  )
  assert_eq(
    preview("<p><span>a</span>\t<span>a</span></p>"),
    "<p><span>a</span> <span>a</span></p>",
  )
  assert_eq(
    preview("<p><span>a</span>\n\t<div>a</div></p>"),
    "<p><span>a</span><div>a</div></p>",
  )
  assert_eq(
    preview("<p><span>a</span> \n <div>a</div></p>"),
    "<p><span>a</span><div>a</div></p>",
  )
  assert_eq(preview("<p><span>a</span>\n{ x }</p>"), "<p><span>a</span> §</p>")
  assert_eq(
    preview("<p><span>a</span>\n\n{ x }</p>"),
    "<p><span>a</span> §</p>",
  )
  assert_eq(preview("<p><span>a</span> text</p>"), "<p><span>a</span> text</p>")
  assert_eq(
    preview("<p><span>a</span>  text</p>"),
    "<p><span>a</span> text</p>",
  )
  assert_eq(
    preview("<p><span>a</span>\ttext</p>"),
    "<p><span>a</span> text</p>",
  )
  assert_eq(
    preview("<p><div>a</div>\n\t<b>a</b></p>"),
    "<p><div>a</div><b>a</b></p>",
  )
  assert_eq(
    preview("<p><div>a</div> \n <b>a</b></p>"),
    "<p><div>a</div><b>a</b></p>",
  )
  assert_eq(
    preview("<p><div>a</div>\n<p>a</p></p>"),
    "<p><div>a</div><p>a</p></p>",
  )
  assert_eq(
    preview("<p><div>a</div>\n\n<p>a</p></p>"),
    "<p><div>a</div><p>a</p></p>",
  )
  assert_eq(
    preview("<p><div>a</div> <span>a</span></p>"),
    "<p><div>a</div><span>a</span></p>",
  )
  assert_eq(
    preview("<p><div>a</div>  <span>a</span></p>"),
    "<p><div>a</div><span>a</span></p>",
  )
  assert_eq(
    preview("<p><div>a</div>\t<span>a</span></p>"),
    "<p><div>a</div><span>a</span></p>",
  )
  assert_eq(preview("<p><div>a</div>\n\t{ x }</p>"), "<p><div>a</div>§</p>")
  assert_eq(preview("<p><div>a</div> \n { x }</p>"), "<p><div>a</div>§</p>")
  assert_eq(preview("<p><div>a</div>\ntext</p>"), "<p><div>a</div>text</p>")
  assert_eq(preview("<p><div>a</div>\n\ntext</p>"), "<p><div>a</div>text</p>")
  assert_eq(preview("<p>{ x } <b>a</b></p>"), "<p>§ <b>a</b></p>")
  assert_eq(preview("<p>{ x }  <b>a</b></p>"), "<p>§ <b>a</b></p>")
  assert_eq(preview("<p>{ x }\t<b>a</b></p>"), "<p>§ <b>a</b></p>")
  assert_eq(preview("<p>{ x }\n\t<p>a</p></p>"), "<p>§<p>a</p></p>")
  assert_eq(preview("<p>{ x } \n <p>a</p></p>"), "<p>§<p>a</p></p>")
  assert_eq(preview("<p>{ x }\n<span>a</span></p>"), "<p>§ <span>a</span></p>")
  assert_eq(
    preview("<p>{ x }\n\n<span>a</span></p>"),
    "<p>§ <span>a</span></p>",
  )
  assert_eq(preview("<p>{ x } <div>a</div></p>"), "<p>§<div>a</div></p>")
  assert_eq(preview("<p>{ x }  <div>a</div></p>"), "<p>§<div>a</div></p>")
  assert_eq(preview("<p>{ x }\t<div>a</div></p>"), "<p>§<div>a</div></p>")
  assert_eq(preview("<p>{ x }\n\ttext</p>"), "<p>§ text</p>")
  assert_eq(preview("<p>{ x } \n text</p>"), "<p>§ text</p>")
  assert_eq(preview("<p>text\n<b>a</b></p>"), "<p>text <b>a</b></p>")
  assert_eq(preview("<p>text\n\n<b>a</b></p>"), "<p>text <b>a</b></p>")
  assert_eq(preview("<p>text <p>a</p></p>"), "<p>text <p>a</p></p>")
  assert_eq(preview("<p>text  <p>a</p></p>"), "<p>text  <p>a</p></p>")
  assert_eq(preview("<p>text\t<p>a</p></p>"), "<p>text\t<p>a</p></p>")
  assert_eq(
    preview("<p>text\n\t<span>a</span></p>"),
    "<p>text <span>a</span></p>",
  )
  assert_eq(
    preview("<p>text \n <span>a</span></p>"),
    "<p>text  <span>a</span></p>",
  )
  assert_eq(preview("<p>text\n<div>a</div></p>"), "<p>text<div>a</div></p>")
  assert_eq(preview("<p>text\n\n<div>a</div></p>"), "<p>text<div>a</div></p>")
  assert_eq(preview("<p>text { x }</p>"), "<p>text §</p>")
  assert_eq(preview("<p>text  { x }</p>"), "<p>text  §</p>")
  assert_eq(preview("<p>text\t{ x }</p>"), "<p>text\t§</p>")
  assert_eq(preview("<div>a</div>"), "<div>a</div>")
  assert_eq(preview("<div> a </div>"), "<div>a </div>")
  assert_eq(preview("<div>a </div>"), "<div>a </div>")
  assert_eq(preview("<div> a</div>"), "<div>a</div>")
  assert_eq(preview("<div>\na\n</div>"), "<div>a</div>")
  assert_eq(preview("<div>a\n</div>"), "<div>a</div>")
  assert_eq(preview("<div>\na</div>"), "<div>a</div>")
  assert_eq(preview("<div>\n\ta\n\t</div>"), "<div>a</div>")
  assert_eq(preview("<div>a\n\t</div>"), "<div>a</div>")
  assert_eq(preview("<div>\n\ta</div>"), "<div>a</div>")
  assert_eq(preview("<div>  a  </div>"), "<div>a  </div>")
  assert_eq(preview("<div>a  </div>"), "<div>a  </div>")
  assert_eq(preview("<div>  a</div>"), "<div>a</div>")
  assert_eq(preview("<div>\n\na\n\n</div>"), "<div>a</div>")
  assert_eq(preview("<div>a\n\n</div>"), "<div>a</div>")
  assert_eq(preview("<div>\n\na</div>"), "<div>a</div>")
  assert_eq(preview("<div> \n a \n </div>"), "<div>a </div>")
  assert_eq(preview("<div>a \n </div>"), "<div>a </div>")
  assert_eq(preview("<div> \n a</div>"), "<div>a</div>")
  assert_eq(preview("<div>\ta\t</div>"), "<div>a\t</div>")
  assert_eq(preview("<div>a\t</div>"), "<div>a\t</div>")
  assert_eq(preview("<div>\ta</div>"), "<div>a</div>")
  assert_eq(preview("<div>b c</div>"), "<div>b c</div>")
  assert_eq(preview("<div> b c </div>"), "<div>b c </div>")
  assert_eq(preview("<div>b c </div>"), "<div>b c </div>")
  assert_eq(preview("<div> b c</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\nb c\n</div>"), "<div>b c</div>")
  assert_eq(preview("<div>b c\n</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\nb c</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\n\tb c\n\t</div>"), "<div>b c</div>")
  assert_eq(preview("<div>b c\n\t</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\n\tb c</div>"), "<div>b c</div>")
  assert_eq(preview("<div>  b c  </div>"), "<div>b c  </div>")
  assert_eq(preview("<div>b c  </div>"), "<div>b c  </div>")
  assert_eq(preview("<div>  b c</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\n\nb c\n\n</div>"), "<div>b c</div>")
  assert_eq(preview("<div>b c\n\n</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\n\nb c</div>"), "<div>b c</div>")
  assert_eq(preview("<div> \n b c \n </div>"), "<div>b c </div>")
  assert_eq(preview("<div>b c \n </div>"), "<div>b c </div>")
  assert_eq(preview("<div> \n b c</div>"), "<div>b c</div>")
  assert_eq(preview("<div>\tb c\t</div>"), "<div>b c\t</div>")
  assert_eq(preview("<div>b c\t</div>"), "<div>b c\t</div>")
  assert_eq(preview("<div>\tb c</div>"), "<div>b c</div>")
  assert_eq(preview("<div>a   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div> a   b </div>"), "<div>a   b </div>")
  assert_eq(preview("<div>a   b </div>"), "<div>a   b </div>")
  assert_eq(preview("<div> a   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\na   b\n</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>a   b\n</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\na   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\n\ta   b\n\t</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>a   b\n\t</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\n\ta   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>  a   b  </div>"), "<div>a   b  </div>")
  assert_eq(preview("<div>a   b  </div>"), "<div>a   b  </div>")
  assert_eq(preview("<div>  a   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\n\na   b\n\n</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>a   b\n\n</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\n\na   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div> \n a   b \n </div>"), "<div>a   b </div>")
  assert_eq(preview("<div>a   b \n </div>"), "<div>a   b </div>")
  assert_eq(preview("<div> \n a   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>\ta   b\t</div>"), "<div>a   b\t</div>")
  assert_eq(preview("<div>a   b\t</div>"), "<div>a   b\t</div>")
  assert_eq(preview("<div>\ta   b</div>"), "<div>a   b</div>")
  assert_eq(preview("<div>{ x }</div>"), "<div>§</div>")
  assert_eq(preview("<div> { x } </div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x } </div>"), "<div>§</div>")
  assert_eq(preview("<div> { x }</div>"), "<div>§</div>")
  assert_eq(preview("<div>\n{ x }\n</div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x }\n</div>"), "<div>§</div>")
  assert_eq(preview("<div>\n{ x }</div>"), "<div>§</div>")
  assert_eq(preview("<div>\n\t{ x }\n\t</div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x }\n\t</div>"), "<div>§</div>")
  assert_eq(preview("<div>\n\t{ x }</div>"), "<div>§</div>")
  assert_eq(preview("<div>  { x }  </div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x }  </div>"), "<div>§</div>")
  assert_eq(preview("<div>  { x }</div>"), "<div>§</div>")
  assert_eq(preview("<div>\n\n{ x }\n\n</div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x }\n\n</div>"), "<div>§</div>")
  assert_eq(preview("<div>\n\n{ x }</div>"), "<div>§</div>")
  assert_eq(preview("<div> \n { x } \n </div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x } \n </div>"), "<div>§</div>")
  assert_eq(preview("<div> \n { x }</div>"), "<div>§</div>")
  assert_eq(preview("<div>\t{ x }\t</div>"), "<div>§</div>")
  assert_eq(preview("<div>{ x }\t</div>"), "<div>§</div>")
  assert_eq(preview("<div>\t{ x }</div>"), "<div>§</div>")
  assert_eq(preview("<div>x{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div> x{y}z </div>"), "<div>x§z </div>")
  assert_eq(preview("<div>x{y}z </div>"), "<div>x§z </div>")
  assert_eq(preview("<div> x{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\nx{y}z\n</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>x{y}z\n</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\nx{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\n\tx{y}z\n\t</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>x{y}z\n\t</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\n\tx{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>  x{y}z  </div>"), "<div>x§z  </div>")
  assert_eq(preview("<div>x{y}z  </div>"), "<div>x§z  </div>")
  assert_eq(preview("<div>  x{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\n\nx{y}z\n\n</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>x{y}z\n\n</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\n\nx{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div> \n x{y}z \n </div>"), "<div>x§z </div>")
  assert_eq(preview("<div>x{y}z \n </div>"), "<div>x§z </div>")
  assert_eq(preview("<div> \n x{y}z</div>"), "<div>x§z</div>")
  assert_eq(preview("<div>\tx{y}z\t</div>"), "<div>x§z\t</div>")
  assert_eq(preview("<div>x{y}z\t</div>"), "<div>x§z\t</div>")
  assert_eq(preview("<div>\tx{y}z</div>"), "<div>x§z</div>")
  assert_eq(
    preview("<div><b>a</b>\n\t<b>a</b></div>"),
    "<div><b>a</b> <b>a</b></div>",
  )
  assert_eq(
    preview("<div><b>a</b> \n <b>a</b></div>"),
    "<div><b>a</b> <b>a</b></div>",
  )
  assert_eq(
    preview("<div><b>a</b>\n<p>a</p></div>"),
    "<div><b>a</b><p>a</p></div>",
  )
  assert_eq(
    preview("<div><b>a</b>\n\n<p>a</p></div>"),
    "<div><b>a</b><p>a</p></div>",
  )
  assert_eq(
    preview("<div><b>a</b> <span>a</span></div>"),
    "<div><b>a</b> <span>a</span></div>",
  )
  assert_eq(
    preview("<div><b>a</b>  <span>a</span></div>"),
    "<div><b>a</b> <span>a</span></div>",
  )
  assert_eq(
    preview("<div><b>a</b>\t<span>a</span></div>"),
    "<div><b>a</b> <span>a</span></div>",
  )
  assert_eq(
    preview("<div><b>a</b>\n\t<div>a</div></div>"),
    "<div><b>a</b><div>a</div></div>",
  )
  assert_eq(
    preview("<div><b>a</b> \n <div>a</div></div>"),
    "<div><b>a</b><div>a</div></div>",
  )
  assert_eq(preview("<div><b>a</b>\n{ x }</div>"), "<div><b>a</b> §</div>")
  assert_eq(preview("<div><b>a</b>\n\n{ x }</div>"), "<div><b>a</b> §</div>")
  assert_eq(preview("<div><b>a</b> text</div>"), "<div><b>a</b> text</div>")
  assert_eq(preview("<div><b>a</b>  text</div>"), "<div><b>a</b> text</div>")
  assert_eq(preview("<div><b>a</b>\ttext</div>"), "<div><b>a</b> text</div>")
  assert_eq(
    preview("<div><p>a</p>\n\t<b>a</b></div>"),
    "<div><p>a</p><b>a</b></div>",
  )
  assert_eq(
    preview("<div><p>a</p> \n <b>a</b></div>"),
    "<div><p>a</p><b>a</b></div>",
  )
  assert_eq(
    preview("<div><p>a</p>\n<p>a</p></div>"),
    "<div><p>a</p><p>a</p></div>",
  )
  assert_eq(
    preview("<div><p>a</p>\n\n<p>a</p></div>"),
    "<div><p>a</p><p>a</p></div>",
  )
  assert_eq(
    preview("<div><p>a</p> <span>a</span></div>"),
    "<div><p>a</p><span>a</span></div>",
  )
  assert_eq(
    preview("<div><p>a</p>  <span>a</span></div>"),
    "<div><p>a</p><span>a</span></div>",
  )
  assert_eq(
    preview("<div><p>a</p>\t<span>a</span></div>"),
    "<div><p>a</p><span>a</span></div>",
  )
  assert_eq(
    preview("<div><p>a</p>\n\t<div>a</div></div>"),
    "<div><p>a</p><div>a</div></div>",
  )
  assert_eq(
    preview("<div><p>a</p> \n <div>a</div></div>"),
    "<div><p>a</p><div>a</div></div>",
  )
  assert_eq(preview("<div><p>a</p>\n{ x }</div>"), "<div><p>a</p>§</div>")
  assert_eq(preview("<div><p>a</p>\n\n{ x }</div>"), "<div><p>a</p>§</div>")
  assert_eq(preview("<div><p>a</p> text</div>"), "<div><p>a</p>text</div>")
  assert_eq(preview("<div><p>a</p>  text</div>"), "<div><p>a</p>text</div>")
  assert_eq(preview("<div><p>a</p>\ttext</div>"), "<div><p>a</p>text</div>")
  assert_eq(
    preview("<div><span>a</span>\n\t<b>a</b></div>"),
    "<div><span>a</span> <b>a</b></div>",
  )
  assert_eq(
    preview("<div><span>a</span> \n <b>a</b></div>"),
    "<div><span>a</span> <b>a</b></div>",
  )
  assert_eq(
    preview("<div><span>a</span>\n<p>a</p></div>"),
    "<div><span>a</span><p>a</p></div>",
  )
  assert_eq(
    preview("<div><span>a</span>\n\n<p>a</p></div>"),
    "<div><span>a</span><p>a</p></div>",
  )
  assert_eq(
    preview("<div><span>a</span> <span>a</span></div>"),
    "<div><span>a</span> <span>a</span></div>",
  )
  assert_eq(
    preview("<div><span>a</span>  <span>a</span></div>"),
    "<div><span>a</span> <span>a</span></div>",
  )
  assert_eq(
    preview("<div><span>a</span>\t<span>a</span></div>"),
    "<div><span>a</span> <span>a</span></div>",
  )
  assert_eq(
    preview("<div><span>a</span>\n\t<div>a</div></div>"),
    "<div><span>a</span><div>a</div></div>",
  )
  assert_eq(
    preview("<div><span>a</span> \n <div>a</div></div>"),
    "<div><span>a</span><div>a</div></div>",
  )
  assert_eq(
    preview("<div><span>a</span>\n{ x }</div>"),
    "<div><span>a</span> §</div>",
  )
  assert_eq(
    preview("<div><span>a</span>\n\n{ x }</div>"),
    "<div><span>a</span> §</div>",
  )
  assert_eq(
    preview("<div><span>a</span> text</div>"),
    "<div><span>a</span> text</div>",
  )
  assert_eq(
    preview("<div><span>a</span>  text</div>"),
    "<div><span>a</span> text</div>",
  )
  assert_eq(
    preview("<div><span>a</span>\ttext</div>"),
    "<div><span>a</span> text</div>",
  )
  assert_eq(
    preview("<div><div>a</div>\n\t<b>a</b></div>"),
    "<div><div>a</div><b>a</b></div>",
  )
  assert_eq(
    preview("<div><div>a</div> \n <b>a</b></div>"),
    "<div><div>a</div><b>a</b></div>",
  )
  assert_eq(
    preview("<div><div>a</div>\n<p>a</p></div>"),
    "<div><div>a</div><p>a</p></div>",
  )
  assert_eq(
    preview("<div><div>a</div>\n\n<p>a</p></div>"),
    "<div><div>a</div><p>a</p></div>",
  )
  assert_eq(
    preview("<div><div>a</div> <span>a</span></div>"),
    "<div><div>a</div><span>a</span></div>",
  )
  assert_eq(
    preview("<div><div>a</div>  <span>a</span></div>"),
    "<div><div>a</div><span>a</span></div>",
  )
  assert_eq(
    preview("<div><div>a</div>\t<span>a</span></div>"),
    "<div><div>a</div><span>a</span></div>",
  )
  assert_eq(
    preview("<div><div>a</div>\n\t{ x }</div>"),
    "<div><div>a</div>§</div>",
  )
  assert_eq(
    preview("<div><div>a</div> \n { x }</div>"),
    "<div><div>a</div>§</div>",
  )
  assert_eq(
    preview("<div><div>a</div>\ntext</div>"),
    "<div><div>a</div>text</div>",
  )
  assert_eq(
    preview("<div><div>a</div>\n\ntext</div>"),
    "<div><div>a</div>text</div>",
  )
  assert_eq(preview("<div>{ x } <b>a</b></div>"), "<div>§ <b>a</b></div>")
  assert_eq(preview("<div>{ x }  <b>a</b></div>"), "<div>§ <b>a</b></div>")
  assert_eq(preview("<div>{ x }\t<b>a</b></div>"), "<div>§ <b>a</b></div>")
  assert_eq(preview("<div>{ x }\n\t<p>a</p></div>"), "<div>§<p>a</p></div>")
  assert_eq(preview("<div>{ x } \n <p>a</p></div>"), "<div>§<p>a</p></div>")
  assert_eq(
    preview("<div>{ x }\n<span>a</span></div>"),
    "<div>§ <span>a</span></div>",
  )
  assert_eq(
    preview("<div>{ x }\n\n<span>a</span></div>"),
    "<div>§ <span>a</span></div>",
  )
  assert_eq(
    preview("<div>{ x } <div>a</div></div>"),
    "<div>§<div>a</div></div>",
  )
  assert_eq(
    preview("<div>{ x }  <div>a</div></div>"),
    "<div>§<div>a</div></div>",
  )
  assert_eq(
    preview("<div>{ x }\t<div>a</div></div>"),
    "<div>§<div>a</div></div>",
  )
  assert_eq(preview("<div>{ x }\n\ttext</div>"), "<div>§ text</div>")
  assert_eq(preview("<div>{ x } \n text</div>"), "<div>§ text</div>")
  assert_eq(preview("<div>text\n<b>a</b></div>"), "<div>text <b>a</b></div>")
  assert_eq(preview("<div>text\n\n<b>a</b></div>"), "<div>text <b>a</b></div>")
  assert_eq(preview("<div>text <p>a</p></div>"), "<div>text <p>a</p></div>")
  assert_eq(preview("<div>text  <p>a</p></div>"), "<div>text  <p>a</p></div>")
  assert_eq(preview("<div>text\t<p>a</p></div>"), "<div>text\t<p>a</p></div>")
  assert_eq(
    preview("<div>text\n\t<span>a</span></div>"),
    "<div>text <span>a</span></div>",
  )
  assert_eq(
    preview("<div>text \n <span>a</span></div>"),
    "<div>text  <span>a</span></div>",
  )
  assert_eq(
    preview("<div>text\n<div>a</div></div>"),
    "<div>text<div>a</div></div>",
  )
  assert_eq(
    preview("<div>text\n\n<div>a</div></div>"),
    "<div>text<div>a</div></div>",
  )
  assert_eq(preview("<div>text { x }</div>"), "<div>text §</div>")
  assert_eq(preview("<div>text  { x }</div>"), "<div>text  §</div>")
  assert_eq(preview("<div>text\t{ x }</div>"), "<div>text\t§</div>")
  assert_eq(preview("<span>a</span>"), "<span>a</span>")
  assert_eq(preview("<span> a </span>"), "<span>a </span>")
  assert_eq(preview("<span>a </span>"), "<span>a </span>")
  assert_eq(preview("<span> a</span>"), "<span>a</span>")
  assert_eq(preview("<span>\na\n</span>"), "<span>a</span>")
  assert_eq(preview("<span>a\n</span>"), "<span>a</span>")
  assert_eq(preview("<span>\na</span>"), "<span>a</span>")
  assert_eq(preview("<span>\n\ta\n\t</span>"), "<span>a</span>")
  assert_eq(preview("<span>a\n\t</span>"), "<span>a</span>")
  assert_eq(preview("<span>\n\ta</span>"), "<span>a</span>")
  assert_eq(preview("<span>  a  </span>"), "<span>a  </span>")
  assert_eq(preview("<span>a  </span>"), "<span>a  </span>")
  assert_eq(preview("<span>  a</span>"), "<span>a</span>")
  assert_eq(preview("<span>\n\na\n\n</span>"), "<span>a</span>")
  assert_eq(preview("<span>a\n\n</span>"), "<span>a</span>")
  assert_eq(preview("<span>\n\na</span>"), "<span>a</span>")
  assert_eq(preview("<span> \n a \n </span>"), "<span>a </span>")
  assert_eq(preview("<span>a \n </span>"), "<span>a </span>")
  assert_eq(preview("<span> \n a</span>"), "<span>a</span>")
  assert_eq(preview("<span>\ta\t</span>"), "<span>a\t</span>")
  assert_eq(preview("<span>a\t</span>"), "<span>a\t</span>")
  assert_eq(preview("<span>\ta</span>"), "<span>a</span>")
  assert_eq(preview("<span>b c</span>"), "<span>b c</span>")
  assert_eq(preview("<span> b c </span>"), "<span>b c </span>")
  assert_eq(preview("<span>b c </span>"), "<span>b c </span>")
  assert_eq(preview("<span> b c</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\nb c\n</span>"), "<span>b c</span>")
  assert_eq(preview("<span>b c\n</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\nb c</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\n\tb c\n\t</span>"), "<span>b c</span>")
  assert_eq(preview("<span>b c\n\t</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\n\tb c</span>"), "<span>b c</span>")
  assert_eq(preview("<span>  b c  </span>"), "<span>b c  </span>")
  assert_eq(preview("<span>b c  </span>"), "<span>b c  </span>")
  assert_eq(preview("<span>  b c</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\n\nb c\n\n</span>"), "<span>b c</span>")
  assert_eq(preview("<span>b c\n\n</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\n\nb c</span>"), "<span>b c</span>")
  assert_eq(preview("<span> \n b c \n </span>"), "<span>b c </span>")
  assert_eq(preview("<span>b c \n </span>"), "<span>b c </span>")
  assert_eq(preview("<span> \n b c</span>"), "<span>b c</span>")
  assert_eq(preview("<span>\tb c\t</span>"), "<span>b c\t</span>")
  assert_eq(preview("<span>b c\t</span>"), "<span>b c\t</span>")
  assert_eq(preview("<span>\tb c</span>"), "<span>b c</span>")
  assert_eq(preview("<span>a   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span> a   b </span>"), "<span>a   b </span>")
  assert_eq(preview("<span>a   b </span>"), "<span>a   b </span>")
  assert_eq(preview("<span> a   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\na   b\n</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>a   b\n</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\na   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\n\ta   b\n\t</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>a   b\n\t</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\n\ta   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>  a   b  </span>"), "<span>a   b  </span>")
  assert_eq(preview("<span>a   b  </span>"), "<span>a   b  </span>")
  assert_eq(preview("<span>  a   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\n\na   b\n\n</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>a   b\n\n</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\n\na   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span> \n a   b \n </span>"), "<span>a   b </span>")
  assert_eq(preview("<span>a   b \n </span>"), "<span>a   b </span>")
  assert_eq(preview("<span> \n a   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>\ta   b\t</span>"), "<span>a   b\t</span>")
  assert_eq(preview("<span>a   b\t</span>"), "<span>a   b\t</span>")
  assert_eq(preview("<span>\ta   b</span>"), "<span>a   b</span>")
  assert_eq(preview("<span>{ x }</span>"), "<span>§</span>")
  assert_eq(preview("<span> { x } </span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x } </span>"), "<span>§</span>")
  assert_eq(preview("<span> { x }</span>"), "<span>§</span>")
  assert_eq(preview("<span>\n{ x }\n</span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x }\n</span>"), "<span>§</span>")
  assert_eq(preview("<span>\n{ x }</span>"), "<span>§</span>")
  assert_eq(preview("<span>\n\t{ x }\n\t</span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x }\n\t</span>"), "<span>§</span>")
  assert_eq(preview("<span>\n\t{ x }</span>"), "<span>§</span>")
  assert_eq(preview("<span>  { x }  </span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x }  </span>"), "<span>§</span>")
  assert_eq(preview("<span>  { x }</span>"), "<span>§</span>")
  assert_eq(preview("<span>\n\n{ x }\n\n</span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x }\n\n</span>"), "<span>§</span>")
  assert_eq(preview("<span>\n\n{ x }</span>"), "<span>§</span>")
  assert_eq(preview("<span> \n { x } \n </span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x } \n </span>"), "<span>§</span>")
  assert_eq(preview("<span> \n { x }</span>"), "<span>§</span>")
  assert_eq(preview("<span>\t{ x }\t</span>"), "<span>§</span>")
  assert_eq(preview("<span>{ x }\t</span>"), "<span>§</span>")
  assert_eq(preview("<span>\t{ x }</span>"), "<span>§</span>")
  assert_eq(preview("<span>x{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span> x{y}z </span>"), "<span>x§z </span>")
  assert_eq(preview("<span>x{y}z </span>"), "<span>x§z </span>")
  assert_eq(preview("<span> x{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\nx{y}z\n</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>x{y}z\n</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\nx{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\n\tx{y}z\n\t</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>x{y}z\n\t</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\n\tx{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>  x{y}z  </span>"), "<span>x§z  </span>")
  assert_eq(preview("<span>x{y}z  </span>"), "<span>x§z  </span>")
  assert_eq(preview("<span>  x{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\n\nx{y}z\n\n</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>x{y}z\n\n</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\n\nx{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span> \n x{y}z \n </span>"), "<span>x§z </span>")
  assert_eq(preview("<span>x{y}z \n </span>"), "<span>x§z </span>")
  assert_eq(preview("<span> \n x{y}z</span>"), "<span>x§z</span>")
  assert_eq(preview("<span>\tx{y}z\t</span>"), "<span>x§z\t</span>")
  assert_eq(preview("<span>x{y}z\t</span>"), "<span>x§z\t</span>")
  assert_eq(preview("<span>\tx{y}z</span>"), "<span>x§z</span>")
  assert_eq(
    preview("<span><b>a</b>\n\t<b>a</b></span>"),
    "<span><b>a</b> <b>a</b></span>",
  )
  assert_eq(
    preview("<span><b>a</b> \n <b>a</b></span>"),
    "<span><b>a</b> <b>a</b></span>",
  )
  assert_eq(
    preview("<span><b>a</b>\n<p>a</p></span>"),
    "<span><b>a</b><p>a</p></span>",
  )
  assert_eq(
    preview("<span><b>a</b>\n\n<p>a</p></span>"),
    "<span><b>a</b><p>a</p></span>",
  )
  assert_eq(
    preview("<span><b>a</b> <span>a</span></span>"),
    "<span><b>a</b> <span>a</span></span>",
  )
  assert_eq(
    preview("<span><b>a</b>  <span>a</span></span>"),
    "<span><b>a</b> <span>a</span></span>",
  )
  assert_eq(
    preview("<span><b>a</b>\t<span>a</span></span>"),
    "<span><b>a</b> <span>a</span></span>",
  )
  assert_eq(
    preview("<span><b>a</b>\n\t<div>a</div></span>"),
    "<span><b>a</b><div>a</div></span>",
  )
  assert_eq(
    preview("<span><b>a</b> \n <div>a</div></span>"),
    "<span><b>a</b><div>a</div></span>",
  )
  assert_eq(preview("<span><b>a</b>\n{ x }</span>"), "<span><b>a</b> §</span>")
  assert_eq(
    preview("<span><b>a</b>\n\n{ x }</span>"),
    "<span><b>a</b> §</span>",
  )
  assert_eq(preview("<span><b>a</b> text</span>"), "<span><b>a</b> text</span>")
  assert_eq(
    preview("<span><b>a</b>  text</span>"),
    "<span><b>a</b> text</span>",
  )
  assert_eq(
    preview("<span><b>a</b>\ttext</span>"),
    "<span><b>a</b> text</span>",
  )
  assert_eq(
    preview("<span><p>a</p>\n\t<b>a</b></span>"),
    "<span><p>a</p><b>a</b></span>",
  )
  assert_eq(
    preview("<span><p>a</p> \n <b>a</b></span>"),
    "<span><p>a</p><b>a</b></span>",
  )
  assert_eq(
    preview("<span><p>a</p>\n<p>a</p></span>"),
    "<span><p>a</p><p>a</p></span>",
  )
  assert_eq(
    preview("<span><p>a</p>\n\n<p>a</p></span>"),
    "<span><p>a</p><p>a</p></span>",
  )
  assert_eq(
    preview("<span><p>a</p> <span>a</span></span>"),
    "<span><p>a</p><span>a</span></span>",
  )
  assert_eq(
    preview("<span><p>a</p>  <span>a</span></span>"),
    "<span><p>a</p><span>a</span></span>",
  )
  assert_eq(
    preview("<span><p>a</p>\t<span>a</span></span>"),
    "<span><p>a</p><span>a</span></span>",
  )
  assert_eq(
    preview("<span><p>a</p>\n\t<div>a</div></span>"),
    "<span><p>a</p><div>a</div></span>",
  )
  assert_eq(
    preview("<span><p>a</p> \n <div>a</div></span>"),
    "<span><p>a</p><div>a</div></span>",
  )
  assert_eq(preview("<span><p>a</p>\n{ x }</span>"), "<span><p>a</p>§</span>")
  assert_eq(
    preview("<span><p>a</p>\n\n{ x }</span>"),
    "<span><p>a</p>§</span>",
  )
  assert_eq(preview("<span><p>a</p> text</span>"), "<span><p>a</p>text</span>")
  assert_eq(preview("<span><p>a</p>  text</span>"), "<span><p>a</p>text</span>")
  assert_eq(preview("<span><p>a</p>\ttext</span>"), "<span><p>a</p>text</span>")
  assert_eq(
    preview("<span><span>a</span>\n\t<b>a</b></span>"),
    "<span><span>a</span> <b>a</b></span>",
  )
  assert_eq(
    preview("<span><span>a</span> \n <b>a</b></span>"),
    "<span><span>a</span> <b>a</b></span>",
  )
  assert_eq(
    preview("<span><span>a</span>\n<p>a</p></span>"),
    "<span><span>a</span><p>a</p></span>",
  )
  assert_eq(
    preview("<span><span>a</span>\n\n<p>a</p></span>"),
    "<span><span>a</span><p>a</p></span>",
  )
  assert_eq(
    preview("<span><span>a</span> <span>a</span></span>"),
    "<span><span>a</span> <span>a</span></span>",
  )
  assert_eq(
    preview("<span><span>a</span>  <span>a</span></span>"),
    "<span><span>a</span> <span>a</span></span>",
  )
  assert_eq(
    preview("<span><span>a</span>\t<span>a</span></span>"),
    "<span><span>a</span> <span>a</span></span>",
  )
  assert_eq(
    preview("<span><span>a</span>\n\t<div>a</div></span>"),
    "<span><span>a</span><div>a</div></span>",
  )
  assert_eq(
    preview("<span><span>a</span> \n <div>a</div></span>"),
    "<span><span>a</span><div>a</div></span>",
  )
  assert_eq(
    preview("<span><span>a</span>\n{ x }</span>"),
    "<span><span>a</span> §</span>",
  )
  assert_eq(
    preview("<span><span>a</span>\n\n{ x }</span>"),
    "<span><span>a</span> §</span>",
  )
  assert_eq(
    preview("<span><span>a</span> text</span>"),
    "<span><span>a</span> text</span>",
  )
  assert_eq(
    preview("<span><span>a</span>  text</span>"),
    "<span><span>a</span> text</span>",
  )
  assert_eq(
    preview("<span><span>a</span>\ttext</span>"),
    "<span><span>a</span> text</span>",
  )
  assert_eq(
    preview("<span><div>a</div>\n\t<b>a</b></span>"),
    "<span><div>a</div><b>a</b></span>",
  )
  assert_eq(
    preview("<span><div>a</div> \n <b>a</b></span>"),
    "<span><div>a</div><b>a</b></span>",
  )
  assert_eq(
    preview("<span><div>a</div>\n<p>a</p></span>"),
    "<span><div>a</div><p>a</p></span>",
  )
  assert_eq(
    preview("<span><div>a</div>\n\n<p>a</p></span>"),
    "<span><div>a</div><p>a</p></span>",
  )
  assert_eq(
    preview("<span><div>a</div> <span>a</span></span>"),
    "<span><div>a</div><span>a</span></span>",
  )
  assert_eq(
    preview("<span><div>a</div>  <span>a</span></span>"),
    "<span><div>a</div><span>a</span></span>",
  )
  assert_eq(
    preview("<span><div>a</div>\t<span>a</span></span>"),
    "<span><div>a</div><span>a</span></span>",
  )
  assert_eq(
    preview("<span><div>a</div>\n\t{ x }</span>"),
    "<span><div>a</div>§</span>",
  )
  assert_eq(
    preview("<span><div>a</div> \n { x }</span>"),
    "<span><div>a</div>§</span>",
  )
  assert_eq(
    preview("<span><div>a</div>\ntext</span>"),
    "<span><div>a</div>text</span>",
  )
  assert_eq(
    preview("<span><div>a</div>\n\ntext</span>"),
    "<span><div>a</div>text</span>",
  )
  assert_eq(preview("<span>{ x } <b>a</b></span>"), "<span>§ <b>a</b></span>")
  assert_eq(preview("<span>{ x }  <b>a</b></span>"), "<span>§ <b>a</b></span>")
  assert_eq(preview("<span>{ x }\t<b>a</b></span>"), "<span>§ <b>a</b></span>")
  assert_eq(
    preview("<span>{ x }\n\t<p>a</p></span>"),
    "<span>§<p>a</p></span>",
  )
  assert_eq(
    preview("<span>{ x } \n <p>a</p></span>"),
    "<span>§<p>a</p></span>",
  )
  assert_eq(
    preview("<span>{ x }\n<span>a</span></span>"),
    "<span>§ <span>a</span></span>",
  )
  assert_eq(
    preview("<span>{ x }\n\n<span>a</span></span>"),
    "<span>§ <span>a</span></span>",
  )
  assert_eq(
    preview("<span>{ x } <div>a</div></span>"),
    "<span>§<div>a</div></span>",
  )
  assert_eq(
    preview("<span>{ x }  <div>a</div></span>"),
    "<span>§<div>a</div></span>",
  )
  assert_eq(
    preview("<span>{ x }\t<div>a</div></span>"),
    "<span>§<div>a</div></span>",
  )
  assert_eq(preview("<span>{ x }\n\ttext</span>"), "<span>§ text</span>")
  assert_eq(preview("<span>{ x } \n text</span>"), "<span>§ text</span>")
  assert_eq(
    preview("<span>text\n<b>a</b></span>"),
    "<span>text <b>a</b></span>",
  )
  assert_eq(
    preview("<span>text\n\n<b>a</b></span>"),
    "<span>text <b>a</b></span>",
  )
  assert_eq(preview("<span>text <p>a</p></span>"), "<span>text <p>a</p></span>")
  assert_eq(
    preview("<span>text  <p>a</p></span>"),
    "<span>text  <p>a</p></span>",
  )
  assert_eq(
    preview("<span>text\t<p>a</p></span>"),
    "<span>text\t<p>a</p></span>",
  )
  assert_eq(
    preview("<span>text\n\t<span>a</span></span>"),
    "<span>text <span>a</span></span>",
  )
  assert_eq(
    preview("<span>text \n <span>a</span></span>"),
    "<span>text  <span>a</span></span>",
  )
  assert_eq(
    preview("<span>text\n<div>a</div></span>"),
    "<span>text<div>a</div></span>",
  )
  assert_eq(
    preview("<span>text\n\n<div>a</div></span>"),
    "<span>text<div>a</div></span>",
  )
  assert_eq(preview("<span>text { x }</span>"), "<span>text §</span>")
  assert_eq(preview("<span>text  { x }</span>"), "<span>text  §</span>")
  assert_eq(preview("<span>text\t{ x }</span>"), "<span>text\t§</span>")
  assert_eq(preview("<b>a</b>"), "<b>a</b>")
  assert_eq(preview("<b> a </b>"), "<b>a </b>")
  assert_eq(preview("<b>a </b>"), "<b>a </b>")
  assert_eq(preview("<b> a</b>"), "<b>a</b>")
  assert_eq(preview("<b>\na\n</b>"), "<b>a</b>")
  assert_eq(preview("<b>a\n</b>"), "<b>a</b>")
  assert_eq(preview("<b>\na</b>"), "<b>a</b>")
  assert_eq(preview("<b>\n\ta\n\t</b>"), "<b>a</b>")
  assert_eq(preview("<b>a\n\t</b>"), "<b>a</b>")
  assert_eq(preview("<b>\n\ta</b>"), "<b>a</b>")
  assert_eq(preview("<b>  a  </b>"), "<b>a  </b>")
  assert_eq(preview("<b>a  </b>"), "<b>a  </b>")
  assert_eq(preview("<b>  a</b>"), "<b>a</b>")
  assert_eq(preview("<b>\n\na\n\n</b>"), "<b>a</b>")
  assert_eq(preview("<b>a\n\n</b>"), "<b>a</b>")
  assert_eq(preview("<b>\n\na</b>"), "<b>a</b>")
  assert_eq(preview("<b> \n a \n </b>"), "<b>a </b>")
  assert_eq(preview("<b>a \n </b>"), "<b>a </b>")
  assert_eq(preview("<b> \n a</b>"), "<b>a</b>")
  assert_eq(preview("<b>\ta\t</b>"), "<b>a\t</b>")
  assert_eq(preview("<b>a\t</b>"), "<b>a\t</b>")
  assert_eq(preview("<b>\ta</b>"), "<b>a</b>")
  assert_eq(preview("<b>b c</b>"), "<b>b c</b>")
  assert_eq(preview("<b> b c </b>"), "<b>b c </b>")
  assert_eq(preview("<b>b c </b>"), "<b>b c </b>")
  assert_eq(preview("<b> b c</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\nb c\n</b>"), "<b>b c</b>")
  assert_eq(preview("<b>b c\n</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\nb c</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\n\tb c\n\t</b>"), "<b>b c</b>")
  assert_eq(preview("<b>b c\n\t</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\n\tb c</b>"), "<b>b c</b>")
  assert_eq(preview("<b>  b c  </b>"), "<b>b c  </b>")
  assert_eq(preview("<b>b c  </b>"), "<b>b c  </b>")
  assert_eq(preview("<b>  b c</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\n\nb c\n\n</b>"), "<b>b c</b>")
  assert_eq(preview("<b>b c\n\n</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\n\nb c</b>"), "<b>b c</b>")
  assert_eq(preview("<b> \n b c \n </b>"), "<b>b c </b>")
  assert_eq(preview("<b>b c \n </b>"), "<b>b c </b>")
  assert_eq(preview("<b> \n b c</b>"), "<b>b c</b>")
  assert_eq(preview("<b>\tb c\t</b>"), "<b>b c\t</b>")
  assert_eq(preview("<b>b c\t</b>"), "<b>b c\t</b>")
  assert_eq(preview("<b>\tb c</b>"), "<b>b c</b>")
  assert_eq(preview("<b>a   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b> a   b </b>"), "<b>a   b </b>")
  assert_eq(preview("<b>a   b </b>"), "<b>a   b </b>")
  assert_eq(preview("<b> a   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\na   b\n</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>a   b\n</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\na   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\n\ta   b\n\t</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>a   b\n\t</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\n\ta   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>  a   b  </b>"), "<b>a   b  </b>")
  assert_eq(preview("<b>a   b  </b>"), "<b>a   b  </b>")
  assert_eq(preview("<b>  a   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\n\na   b\n\n</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>a   b\n\n</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\n\na   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b> \n a   b \n </b>"), "<b>a   b </b>")
  assert_eq(preview("<b>a   b \n </b>"), "<b>a   b </b>")
  assert_eq(preview("<b> \n a   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>\ta   b\t</b>"), "<b>a   b\t</b>")
  assert_eq(preview("<b>a   b\t</b>"), "<b>a   b\t</b>")
  assert_eq(preview("<b>\ta   b</b>"), "<b>a   b</b>")
  assert_eq(preview("<b>{ x }</b>"), "<b>§</b>")
  assert_eq(preview("<b> { x } </b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x } </b>"), "<b>§</b>")
  assert_eq(preview("<b> { x }</b>"), "<b>§</b>")
  assert_eq(preview("<b>\n{ x }\n</b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x }\n</b>"), "<b>§</b>")
  assert_eq(preview("<b>\n{ x }</b>"), "<b>§</b>")
  assert_eq(preview("<b>\n\t{ x }\n\t</b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x }\n\t</b>"), "<b>§</b>")
  assert_eq(preview("<b>\n\t{ x }</b>"), "<b>§</b>")
  assert_eq(preview("<b>  { x }  </b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x }  </b>"), "<b>§</b>")
  assert_eq(preview("<b>  { x }</b>"), "<b>§</b>")
  assert_eq(preview("<b>\n\n{ x }\n\n</b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x }\n\n</b>"), "<b>§</b>")
  assert_eq(preview("<b>\n\n{ x }</b>"), "<b>§</b>")
  assert_eq(preview("<b> \n { x } \n </b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x } \n </b>"), "<b>§</b>")
  assert_eq(preview("<b> \n { x }</b>"), "<b>§</b>")
  assert_eq(preview("<b>\t{ x }\t</b>"), "<b>§</b>")
  assert_eq(preview("<b>{ x }\t</b>"), "<b>§</b>")
  assert_eq(preview("<b>\t{ x }</b>"), "<b>§</b>")
  assert_eq(preview("<b>x{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b> x{y}z </b>"), "<b>x§z </b>")
  assert_eq(preview("<b>x{y}z </b>"), "<b>x§z </b>")
  assert_eq(preview("<b> x{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\nx{y}z\n</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>x{y}z\n</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\nx{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\n\tx{y}z\n\t</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>x{y}z\n\t</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\n\tx{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>  x{y}z  </b>"), "<b>x§z  </b>")
  assert_eq(preview("<b>x{y}z  </b>"), "<b>x§z  </b>")
  assert_eq(preview("<b>  x{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\n\nx{y}z\n\n</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>x{y}z\n\n</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\n\nx{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b> \n x{y}z \n </b>"), "<b>x§z </b>")
  assert_eq(preview("<b>x{y}z \n </b>"), "<b>x§z </b>")
  assert_eq(preview("<b> \n x{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b>\tx{y}z\t</b>"), "<b>x§z\t</b>")
  assert_eq(preview("<b>x{y}z\t</b>"), "<b>x§z\t</b>")
  assert_eq(preview("<b>\tx{y}z</b>"), "<b>x§z</b>")
  assert_eq(preview("<b><b>a</b>\n\t<b>a</b></b>"), "<b><b>a</b> <b>a</b></b>")
  assert_eq(preview("<b><b>a</b> \n <b>a</b></b>"), "<b><b>a</b> <b>a</b></b>")
  assert_eq(preview("<b><b>a</b>\n<p>a</p></b>"), "<b><b>a</b><p>a</p></b>")
  assert_eq(preview("<b><b>a</b>\n\n<p>a</p></b>"), "<b><b>a</b><p>a</p></b>")
  assert_eq(
    preview("<b><b>a</b> <span>a</span></b>"),
    "<b><b>a</b> <span>a</span></b>",
  )
  assert_eq(
    preview("<b><b>a</b>  <span>a</span></b>"),
    "<b><b>a</b> <span>a</span></b>",
  )
  assert_eq(
    preview("<b><b>a</b>\t<span>a</span></b>"),
    "<b><b>a</b> <span>a</span></b>",
  )
  assert_eq(
    preview("<b><b>a</b>\n\t<div>a</div></b>"),
    "<b><b>a</b><div>a</div></b>",
  )
  assert_eq(
    preview("<b><b>a</b> \n <div>a</div></b>"),
    "<b><b>a</b><div>a</div></b>",
  )
  assert_eq(preview("<b><b>a</b>\n{ x }</b>"), "<b><b>a</b> §</b>")
  assert_eq(preview("<b><b>a</b>\n\n{ x }</b>"), "<b><b>a</b> §</b>")
  assert_eq(preview("<b><b>a</b> text</b>"), "<b><b>a</b> text</b>")
  assert_eq(preview("<b><b>a</b>  text</b>"), "<b><b>a</b> text</b>")
  assert_eq(preview("<b><b>a</b>\ttext</b>"), "<b><b>a</b> text</b>")
  assert_eq(preview("<b><p>a</p>\n\t<b>a</b></b>"), "<b><p>a</p><b>a</b></b>")
  assert_eq(preview("<b><p>a</p> \n <b>a</b></b>"), "<b><p>a</p><b>a</b></b>")
  assert_eq(preview("<b><p>a</p>\n<p>a</p></b>"), "<b><p>a</p><p>a</p></b>")
  assert_eq(preview("<b><p>a</p>\n\n<p>a</p></b>"), "<b><p>a</p><p>a</p></b>")
  assert_eq(
    preview("<b><p>a</p> <span>a</span></b>"),
    "<b><p>a</p><span>a</span></b>",
  )
  assert_eq(
    preview("<b><p>a</p>  <span>a</span></b>"),
    "<b><p>a</p><span>a</span></b>",
  )
  assert_eq(
    preview("<b><p>a</p>\t<span>a</span></b>"),
    "<b><p>a</p><span>a</span></b>",
  )
  assert_eq(
    preview("<b><p>a</p>\n\t<div>a</div></b>"),
    "<b><p>a</p><div>a</div></b>",
  )
  assert_eq(
    preview("<b><p>a</p> \n <div>a</div></b>"),
    "<b><p>a</p><div>a</div></b>",
  )
  assert_eq(preview("<b><p>a</p>\n{ x }</b>"), "<b><p>a</p>§</b>")
  assert_eq(preview("<b><p>a</p>\n\n{ x }</b>"), "<b><p>a</p>§</b>")
  assert_eq(preview("<b><p>a</p> text</b>"), "<b><p>a</p>text</b>")
  assert_eq(preview("<b><p>a</p>  text</b>"), "<b><p>a</p>text</b>")
  assert_eq(preview("<b><p>a</p>\ttext</b>"), "<b><p>a</p>text</b>")
  assert_eq(
    preview("<b><span>a</span>\n\t<b>a</b></b>"),
    "<b><span>a</span> <b>a</b></b>",
  )
  assert_eq(
    preview("<b><span>a</span> \n <b>a</b></b>"),
    "<b><span>a</span> <b>a</b></b>",
  )
  assert_eq(
    preview("<b><span>a</span>\n<p>a</p></b>"),
    "<b><span>a</span><p>a</p></b>",
  )
  assert_eq(
    preview("<b><span>a</span>\n\n<p>a</p></b>"),
    "<b><span>a</span><p>a</p></b>",
  )
  assert_eq(
    preview("<b><span>a</span> <span>a</span></b>"),
    "<b><span>a</span> <span>a</span></b>",
  )
  assert_eq(
    preview("<b><span>a</span>  <span>a</span></b>"),
    "<b><span>a</span> <span>a</span></b>",
  )
  assert_eq(
    preview("<b><span>a</span>\t<span>a</span></b>"),
    "<b><span>a</span> <span>a</span></b>",
  )
  assert_eq(
    preview("<b><span>a</span>\n\t<div>a</div></b>"),
    "<b><span>a</span><div>a</div></b>",
  )
  assert_eq(
    preview("<b><span>a</span> \n <div>a</div></b>"),
    "<b><span>a</span><div>a</div></b>",
  )
  assert_eq(preview("<b><span>a</span>\n{ x }</b>"), "<b><span>a</span> §</b>")
  assert_eq(
    preview("<b><span>a</span>\n\n{ x }</b>"),
    "<b><span>a</span> §</b>",
  )
  assert_eq(preview("<b><span>a</span> text</b>"), "<b><span>a</span> text</b>")
  assert_eq(
    preview("<b><span>a</span>  text</b>"),
    "<b><span>a</span> text</b>",
  )
  assert_eq(
    preview("<b><span>a</span>\ttext</b>"),
    "<b><span>a</span> text</b>",
  )
  assert_eq(
    preview("<b><div>a</div>\n\t<b>a</b></b>"),
    "<b><div>a</div><b>a</b></b>",
  )
  assert_eq(
    preview("<b><div>a</div> \n <b>a</b></b>"),
    "<b><div>a</div><b>a</b></b>",
  )
  assert_eq(
    preview("<b><div>a</div>\n<p>a</p></b>"),
    "<b><div>a</div><p>a</p></b>",
  )
  assert_eq(
    preview("<b><div>a</div>\n\n<p>a</p></b>"),
    "<b><div>a</div><p>a</p></b>",
  )
  assert_eq(
    preview("<b><div>a</div> <span>a</span></b>"),
    "<b><div>a</div><span>a</span></b>",
  )
  assert_eq(
    preview("<b><div>a</div>  <span>a</span></b>"),
    "<b><div>a</div><span>a</span></b>",
  )
  assert_eq(
    preview("<b><div>a</div>\t<span>a</span></b>"),
    "<b><div>a</div><span>a</span></b>",
  )
  assert_eq(preview("<b><div>a</div>\n\t{ x }</b>"), "<b><div>a</div>§</b>")
  assert_eq(preview("<b><div>a</div> \n { x }</b>"), "<b><div>a</div>§</b>")
  assert_eq(preview("<b><div>a</div>\ntext</b>"), "<b><div>a</div>text</b>")
  assert_eq(preview("<b><div>a</div>\n\ntext</b>"), "<b><div>a</div>text</b>")
  assert_eq(preview("<b>{ x } <b>a</b></b>"), "<b>§ <b>a</b></b>")
  assert_eq(preview("<b>{ x }  <b>a</b></b>"), "<b>§ <b>a</b></b>")
  assert_eq(preview("<b>{ x }\t<b>a</b></b>"), "<b>§ <b>a</b></b>")
  assert_eq(preview("<b>{ x }\n\t<p>a</p></b>"), "<b>§<p>a</p></b>")
  assert_eq(preview("<b>{ x } \n <p>a</p></b>"), "<b>§<p>a</p></b>")
  assert_eq(preview("<b>{ x }\n<span>a</span></b>"), "<b>§ <span>a</span></b>")
  assert_eq(
    preview("<b>{ x }\n\n<span>a</span></b>"),
    "<b>§ <span>a</span></b>",
  )
  assert_eq(preview("<b>{ x } <div>a</div></b>"), "<b>§<div>a</div></b>")
  assert_eq(preview("<b>{ x }  <div>a</div></b>"), "<b>§<div>a</div></b>")
  assert_eq(preview("<b>{ x }\t<div>a</div></b>"), "<b>§<div>a</div></b>")
  assert_eq(preview("<b>{ x }\n\ttext</b>"), "<b>§ text</b>")
  assert_eq(preview("<b>{ x } \n text</b>"), "<b>§ text</b>")
  assert_eq(preview("<b>text\n<b>a</b></b>"), "<b>text <b>a</b></b>")
  assert_eq(preview("<b>text\n\n<b>a</b></b>"), "<b>text <b>a</b></b>")
  assert_eq(preview("<b>text <p>a</p></b>"), "<b>text <p>a</p></b>")
  assert_eq(preview("<b>text  <p>a</p></b>"), "<b>text  <p>a</p></b>")
  assert_eq(preview("<b>text\t<p>a</p></b>"), "<b>text\t<p>a</p></b>")
  assert_eq(
    preview("<b>text\n\t<span>a</span></b>"),
    "<b>text <span>a</span></b>",
  )
  assert_eq(
    preview("<b>text \n <span>a</span></b>"),
    "<b>text  <span>a</span></b>",
  )
  assert_eq(preview("<b>text\n<div>a</div></b>"), "<b>text<div>a</div></b>")
  assert_eq(preview("<b>text\n\n<div>a</div></b>"), "<b>text<div>a</div></b>")
  assert_eq(preview("<b>text { x }</b>"), "<b>text §</b>")
  assert_eq(preview("<b>text  { x }</b>"), "<b>text  §</b>")
  assert_eq(preview("<b>text\t{ x }</b>"), "<b>text\t§</b>")
}

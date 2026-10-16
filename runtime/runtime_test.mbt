///|
test "escape covers the fixed table" {
  assert_eq(@runtime.escape("&"), "&amp;")
  assert_eq(@runtime.escape("'"), "&#39;")
  assert_eq(@runtime.escape("<"), "&lt;")
  assert_eq(@runtime.escape(">"), "&gt;")
  assert_eq(@runtime.escape("\""), "&#34;")
}

///|
test "escape replaces every occurrence, not just the first" {
  assert_eq(@runtime.escape("a&b&c"), "a&amp;b&amp;c")
}

///|
test "escape leaves ordinary text untouched" {
  assert_eq(@runtime.escape(""), "")
  assert_eq(@runtime.escape("hello 世界"), "hello 世界")
}

///|
test "component renders to string through Show" {
  let c = @runtime.component(fn(_ctx, w) { w.write_string("<b>hi</b>") })
  assert_eq(c.to_string(), "<b>hi</b>")
}

///|
test "write_any renders Show values and escapes them" {
  let c = @runtime.component(fn(_ctx, w) {
    @runtime.write_any(w, "a<b")
    @runtime.write_any(w, 42)
    @runtime.write_any(w, 1.5)
    @runtime.write_any(w, true)
  })
  assert_eq(c.to_string(), "a&lt;b421.5true")
}

///|
test "raw bypasses escaping" {
  assert_eq(@runtime.raw("<b>x</b>").to_string(), "<b>x</b>")
}

///|
test "children render where the component asks for them" {
  let leaf = @runtime.component(fn(_ctx, w) { w.write_string("LEAF") })
  let wrapper = @runtime.component(fn(ctx, w) {
    let children = ctx.children
    let ctx = ctx.clear_children()
    w.write_string("<i>")
    children.render(ctx, w)
    w.write_string("</i>")
  })
  assert_eq(wrapper.with_children(leaf).to_string(), "<i>LEAF</i>")
}

///|
test "children do not leak down to grandchildren" {
  let leaf = @runtime.component(fn(_ctx, w) { w.write_string("LEAF") })
  let inner = @runtime.component(fn(ctx, w) {
    let children = ctx.children
    let ctx = ctx.clear_children()
    w.write_string("<i>")
    children.render(ctx, w)
    w.write_string("</i>")
  })
  let outer = @runtime.component(fn(ctx, w) {
    let children = ctx.children
    let ctx = ctx.clear_children()
    w.write_string("<o>")
    inner.render(ctx, w)
    w.write_string("</o>")
    children.render(ctx, w)
  })
  assert_eq(outer.with_children(leaf).to_string(), "<o><i></i></o>LEAF")
}

///|
test "a component with no children renders an empty shell" {
  let outer = @runtime.component(fn(ctx, w) {
    let children = ctx.children
    let ctx = ctx.clear_children()
    w.write_string("<o>")
    children.render(ctx, w)
    w.write_string("</o>")
  })
  assert_eq(outer.to_string(), "<o></o>")
}

///|
/// The posts the page renders: one of each kind, so a single rendering covers
/// both sides of the condition.
fn posts() -> Array[Post] {
  [
    { title: "Hello, MoonBit", body: "The first post.", published: true, },
    {
      title: "Still writing",
      body: "This one is not out yet.",
      published: false,
    },
  ]
}

///|
/// The whole page in one expectation: a layout from this package with the list
/// handed to it as children, a loop over the posts, an `if` that picks between
/// a card and a draft marker, and the card itself rendered by a call into the
/// `ui` package.
///
/// The markup carries no whitespace between the tags, which is what templ
/// generates for this template too: the runs of whitespace that separate the
/// tags in the source are the ones that lead or trail a block, so they are the
/// block's business rather than the document's. The layout's doctype comes out
/// lowercased for the same reason it does in templ.
test "a page renders a layout, a loop, a condition and a card from another package" {
  assert_eq(
    page("Blog", posts()).to_string(),
    "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">" +
    "<title>Blog</title></head><body><header class=\"site-header\">" +
    "<h1>Blog</h1></header><main class=\"site-main\"><ul class=\"posts\">" +
    "<li class=\"post\"><article class=\"card\">" +
    "<h2 class=\"card-title\">Hello, MoonBit</h2>" +
    "<p class=\"card-body\">The first post.</p></article></li>" +
    "<li class=\"post\"><span class=\"draft\">Still writing</span></li>" +
    "</ul></main></body></html>",
  )
}

///|
/// Nothing to list is not nothing to render: the layout still wraps the page,
/// and the loop leaves the list it wrote around empty.
test "a page with no posts is still a page" {
  assert_eq(
    page("Blog", []).to_string(),
    "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">" +
    "<title>Blog</title></head><body><header class=\"site-header\">" +
    "<h1>Blog</h1></header><main class=\"site-main\">" +
    "<ul class=\"posts\"></ul></main></body></html>",
  )
}

///|
/// What the data holds is text, not markup, and it reaches the output escaped —
/// both where the page writes it itself and where the card in the other package
/// does.
test "text from the data is escaped" {
  let post : Post = {
    title: "Tea & crumpets <3",
    body: "5 > 4",
    published: true,
  }
  assert_eq(
    page("Q&A", [post]).to_string(),
    "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">" +
    "<title>Q&amp;A</title></head><body><header class=\"site-header\">" +
    "<h1>Q&amp;A</h1></header><main class=\"site-main\"><ul class=\"posts\">" +
    "<li class=\"post\"><article class=\"card\">" +
    "<h2 class=\"card-title\">Tea &amp; crumpets &lt;3</h2>" +
    "<p class=\"card-body\">5 &gt; 4</p></article></li>" +
    "</ul></main></body></html>",
  )
}

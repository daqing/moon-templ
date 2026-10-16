///|
fn main {
  let posts : Array[Post] = [
    { title: "Hello, MoonBit", body: "The first post.", published: true, },
    {
      title: "Still writing",
      body: "This one is not out yet.",
      published: false,
    },
  ]
  println(page("Blog", posts).to_string())
}

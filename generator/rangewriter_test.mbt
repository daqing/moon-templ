///|
/// Drive a writer over a fresh buffer and hand back both what was written and
/// the literals it collected.
fn run(script : (@generator.RangeWriter) -> Unit) -> (String, Array[String]) {
  let out = StringBuilder()
  let w = @generator.RangeWriter::new(out)
  script(w)
  w.write_code("")
  (out.to_string(), w.literals())
}

///|
fn lines(s : String) -> Array[String] {
  s.split("\n").map(fn(v) { v.to_owned() }).collect()
}

///|
test "adjacent literals merge into one write_string" {
  let (out, literals) = run(fn(w) {
    w.write_literal("<div>")
    w.write_literal("hello")
    w.write_literal("</div>")
  })
  assert_eq(out, "w.write_string(\"<div>hello</div>\")\n")
  assert_eq(literals, ["<div>hello</div>"])
}

///|
test "code splits a literal run into two write_string calls" {
  let (out, literals) = run(fn(w) {
    w.write_literal("<div>")
    w.write_code("w.write_any(name)\n")
    w.write_literal("</div>")
  })
  assert_eq(lines(out), [
    "w.write_string(\"<div>\")", "w.write_any(name)", "w.write_string(\"</div>\")",
    "",
  ])
  assert_eq(literals, ["<div>", "</div>"])
}

///|
test "literal indices increase across the whole file" {
  let (_, literals) = run(fn(w) {
    w.write_literal("a")
    w.write_code("code1\n")
    w.write_literal("b")
    w.write_code("code2\n")
    w.write_literal("c")
  })
  assert_eq(literals, ["a", "b", "c"])
}

///|
test "a run left open is flushed by whatever code comes next" {
  let (out, literals) = run(fn(w) { w.write_literal("<p>") })
  assert_eq(out, "w.write_string(\"<p>\")\n")
  assert_eq(literals, ["<p>"])
}

///|
test "an empty run emits nothing" {
  let (out, literals) = run(fn(w) { w.write_literal("") })
  assert_eq(out, "")
  assert_eq(literals, [])
}

///|
test "code written inside a literal run keeps its own spelling" {
  let (out, _) = run(fn(w) {
    w.write_code("let x = 1\n")
    w.write_literal("a")
    w.write_code("let y = 2\n")
  })
  assert_eq(out, "let x = 1\nw.write_string(\"a\")\nlet y = 2\n")
}

///|
test "write_indent indents the flushed literal and the code that follows" {
  let (out, _) = run(fn(w) {
    w.write_indent(2, "let x = 1\n")
    w.write_indent(2, "let y = 2\n")
    w.write_literal("a")
    w.write_indent(1, "let z = 3\n")
  })
  assert_eq(lines(out), [
    "    let x = 1", "    let y = 2", "  w.write_string(\"a\")", "  let z = 3", "",
  ])
}

///|
test "in_literal reports whether a run is still open" {
  let out = StringBuilder()
  let w = @generator.RangeWriter::new(out)
  assert_false(w.in_literal())
  w.write_literal("a")
  assert_true(w.in_literal())
  w.write_code("")
  assert_false(w.in_literal())
}

///|
test "literals are quoted for MoonBit, not for HTML" {
  let (out, literals) = run(fn(w) { w.write_literal("a\"b\\c") })
  assert_eq(out, "w.write_string(\"a\\\"b\\\\c\")\n")
  assert_eq(literals, ["a\"b\\c"])
}

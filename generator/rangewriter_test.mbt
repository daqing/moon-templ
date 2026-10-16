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
    w.write_literal(0, "<div>")
    w.write_literal(0, "hello")
    w.write_literal(0, "</div>")
  })
  assert_eq(out, "w.write_string(\"<div>hello</div>\")\n")
  assert_eq(literals, ["<div>hello</div>"])
}

///|
test "code splits a literal run into two write_string calls" {
  let (out, literals) = run(fn(w) {
    w.write_literal(0, "<div>")
    w.write_code("w.write_any(name)\n")
    w.write_literal(0, "</div>")
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
    w.write_literal(0, "a")
    w.write_code("code1\n")
    w.write_literal(0, "b")
    w.write_code("code2\n")
    w.write_literal(0, "c")
  })
  assert_eq(literals, ["a", "b", "c"])
}

///|
test "a run left open is flushed by whatever code comes next" {
  let (out, literals) = run(fn(w) { w.write_literal(0, "<p>") })
  assert_eq(out, "w.write_string(\"<p>\")\n")
  assert_eq(literals, ["<p>"])
}

///|
test "an empty run emits nothing" {
  let (out, literals) = run(fn(w) { w.write_literal(0, "") })
  assert_eq(out, "")
  assert_eq(literals, [])
}

///|
test "code written inside a literal run keeps its own spelling" {
  let (out, _) = run(fn(w) {
    w.write_code("let x = 1\n")
    w.write_literal(0, "a")
    w.write_code("let y = 2\n")
  })
  assert_eq(out, "let x = 1\nw.write_string(\"a\")\nlet y = 2\n")
}

///|
test "a literal lands at the level it was written at, not the flusher's" {
  let (out, _) = run(fn(w) {
    w.write_indent(2, "let x = 1\n")
    w.write_indent(2, "let y = 2\n")
    w.write_literal(2, "a")
    w.write_indent(1, "let z = 3\n")
  })
  assert_eq(lines(out), [
    "    let x = 1", "    let y = 2", "    w.write_string(\"a\")", "  let z = 3",
    "",
  ])
}

///|
test "a run is indented where it started" {
  let (out, _) = run(fn(w) {
    w.write_literal(2, "<div>")
    w.write_literal(3, "text")
  })
  assert_eq(out, "    w.write_string(\"<div>text\")\n")
}

///|
/// The run that opens an element and runs on through its closing tag is written
/// at the element's level, not at the level of the children inside it.
test "a run is indented at the outermost level it spans" {
  let (out, _) = run(fn(w) {
    w.write_literal(3, "text")
    w.write_literal(2, "</div>")
    w.write_literal(3, "tail")
  })
  assert_eq(out, "    w.write_string(\"text</div>tail\")\n")
}

///|
test "in_literal reports whether a run is still open" {
  let out = StringBuilder()
  let w = @generator.RangeWriter::new(out)
  assert_false(w.in_literal())
  w.write_literal(0, "a")
  assert_true(w.in_literal())
  w.write_code("")
  assert_false(w.in_literal())
}

///|
test "literals are quoted for MoonBit, not for HTML" {
  let (out, literals) = run(fn(w) { w.write_literal(0, "a\"b\\c") })
  assert_eq(out, "w.write_string(\"a\\\"b\\\\c\")\n")
  assert_eq(literals, ["a\"b\\c"])
}

///|
/// A writer for generated source that works in two modes.
///
/// Text handed over as a literal is buffered rather than written out. Anything
/// else counts as code, and flushes the buffer first. That is what turns a run
/// of adjacent text nodes into a single `w.write_string` call instead of one call
/// per node, and what gives every literal its position in file order.
pub struct RangeWriter {
  priv out : &Logger
  priv mut in_literal : Bool
  priv mut literal_level : Int32
  priv buf : StringBuilder
  priv literals : Array[String]
}

///|
pub fn RangeWriter::new(out : &Logger) -> RangeWriter {
  {
    out,
    in_literal: false,
    literal_level: 0,
    buf: StringBuilder(),
    literals: [],
  }
}

///|
/// The literals flushed so far, in the order the generated code writes them.
pub fn RangeWriter::literals(self : RangeWriter) -> Array[String] {
  self.literals
}

///|
pub fn RangeWriter::in_literal(self : RangeWriter) -> Bool {
  self.in_literal
}

///|
/// Accumulate literal text at `level` two-space indents. Nothing reaches the
/// output until some code, or the end of the file, forces a flush.
///
/// The level belongs to the literal rather than to whatever flushes it: the run
/// that ends a body is flushed by the closing brace a level further out, and
/// should still be indented where it was written. A run takes the outermost
/// level it spans, so one that opens an element and runs on through its closing
/// tag lines up with the tag rather than with the children inside it.
pub fn RangeWriter::write_literal(
  self : RangeWriter,
  level : Int32,
  s : String,
) -> Unit {
  if !self.in_literal {
    self.in_literal = true
    self.literal_level = level
  } else if level < self.literal_level {
    self.literal_level = level
  }
  self.buf.write_string(s)
}

///|
/// Write code verbatim, flushing any pending literal first.
pub fn RangeWriter::write_code(self : RangeWriter, s : String) -> Unit {
  self.flush_literal()
  self.out.write_string(s)
}

///|
/// Write a line of code at `level` two-space indents, flushing any pending
/// literal first. The caller supplies the newline.
pub fn RangeWriter::write_indent(
  self : RangeWriter,
  level : Int32,
  s : String,
) -> Unit {
  self.flush_literal()
  self.indent(level)
  self.out.write_string(s)
}

///|
fn RangeWriter::flush_literal(self : RangeWriter) -> Unit {
  if !self.in_literal {
    return
  }
  self.in_literal = false
  let literal = self.buf.to_string()
  self.buf.reset()
  if literal.is_empty() {
    return
  }
  self.literals.push(literal)
  self.indent(self.literal_level)
  self.out.write_string("w.write_string(" + string_literal(literal) + ")\n")
}

///|
fn RangeWriter::indent(self : RangeWriter, level : Int32) -> Unit {
  let mut i = 0
  while i < level {
    self.out.write_string("  ")
    i = i + 1
  }
}

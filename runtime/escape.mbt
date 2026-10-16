///|
pub fn escape(s : String) -> String {
  let buf = StringBuilder()
  write_escaped(buf, s)
  buf.to_string()
}

///|
pub fn write_escaped(w : &Logger, s : String) -> Unit {
  for c in s.iter() {
    match c {
      '&' => w.write_string("&amp;")
      '"' => w.write_string("&#34;")
      '\'' => w.write_string("&#39;")
      '<' => w.write_string("&lt;")
      '>' => w.write_string("&gt;")
      _ => w.write_char(c)
    }
  }
}

///|
pub fn[T : Show] write_any(w : &Logger, v : T) -> Unit {
  write_escaped(w, v.to_string())
}

///|
pub fn raw(s : String) -> Component {
  component(fn(_ctx, w) { w.write_string(s) })
}

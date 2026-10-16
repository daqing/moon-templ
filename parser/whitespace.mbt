///|
/// Elements that HTML lays out as blocks. Whitespace next to one of these is
/// dropped, while whitespace between two inline nodes collapses to a single
/// space. The trailing group is not strictly block, but templ treats it as such
/// for layout purposes.
pub fn is_block_element(name : String) -> Bool {
  match name {
    "address"
    | "article"
    | "aside"
    | "body"
    | "blockquote"
    | "canvas"
    | "dd"
    | "div"
    | "dl"
    | "dt"
    | "fieldset"
    | "figcaption"
    | "figure"
    | "footer"
    | "form"
    | "h1"
    | "h2"
    | "h3"
    | "h4"
    | "h5"
    | "h6"
    | "head"
    | "header"
    | "hr"
    | "html"
    | "li"
    | "main"
    | "meta"
    | "nav"
    | "noscript"
    | "ol"
    | "p"
    | "pre"
    | "script"
    | "section"
    | "table"
    | "template"
    | "tfoot"
    | "turbo-stream"
    | "ul"
    | "video"
    | "title"
    | "style"
    | "link"
    | "td"
    | "th"
    | "tr"
    | "br" => true
    _ => false
  }
}

///|
/// Whether a node counts as inline content when deciding to keep a space next to
/// it. Control flow and component calls are inline; comments and doctypes are
/// not.
pub fn is_inline(node : Node) -> Bool {
  match node {
    Text(_) | StringExpression(_) => true
    Element(e) => !is_block_element(e.name)
    _ => false
  }
}

///|
/// A text run is broken into the parts that survive whitespace normalization.
priv enum Piece {
  /// A run of template text with no whitespace in it, kept verbatim.
  Literal(String)
  /// A whitespace run that collapses to one space, or disappears entirely.
  Gap
  /// Any other node.
  Nested(Node)
}

///|
/// Normalize whitespace in a node list.
///
/// Whitespace inside a line of text is kept verbatim. A whitespace run that
/// starts a text node, or that contains a newline, becomes a single space when
/// it sits between two inline nodes and is dropped otherwise. That reproduces
/// templ's rule of consuming the whitespace that trails a node, while leaving
/// the run that precedes a tag inside the text itself.
pub fn normalize_whitespace(nodes : Array[Node]) -> Array[Node] {
  let pieces : Array[Piece] = []
  for node in nodes {
    collect(node, pieces)
  }
  emit(pieces)
}

///|
fn collect(node : Node, out : Array[Piece]) -> Unit {
  match node {
    Text(value) => split_text(value, out)
    Element(e) =>
      out.push(
        Nested(
          Element({
            name: e.name,
            attrs: e.attrs,
            children: normalize_whitespace(e.children),
            self_closing: e.self_closing,
          }),
        ),
      )
    _ => out.push(Nested(node))
  }
}

///|
fn split_text(value : String, out : Array[Piece]) -> Unit {
  let chars = value.to_array()
  let len = chars.length()
  let mut i = 0
  let mut first = true
  while i < len {
    let is_ws = is_space(chars[i])
    let mut j = i
    while j < len && is_space(chars[j]) == is_ws {
      j = j + 1
    }
    if !is_ws {
      out.push(Literal(build(chars, i, j)))
    } else {
      // Whitespace leading a text node belongs to the whitespace that trailed
      // the previous node, so the whole run collapses. Later runs only collapse
      // from the first newline onwards; the spaces before it are part of the
      // line and survive verbatim.
      let mut split = if first { i } else { -1 }
      if split < 0 {
        for k = i; k < j; k = k + 1 {
          if split < 0 && chars[k] == '\n' {
            split = k
          }
        }
      }
      if split < 0 {
        out.push(Literal(build(chars, i, j)))
      } else {
        if split > i {
          out.push(Literal(build(chars, i, split)))
        }
        out.push(Gap)
      }
    }
    first = false
    i = j
  }
}

///|
fn build(chars : Array[Char], from : Int32, to : Int32) -> String {
  let buf = StringBuilder()
  for i = from; i < to; i = i + 1 {
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
fn emit(pieces : Array[Piece]) -> Array[Node] {
  let out : Array[Node] = []
  for i, piece in pieces {
    match piece {
      Nested(node) => out.push(node)
      Literal(value) => out.push(Text(value))
      Gap =>
        if i > 0 &&
          i + 1 < pieces.length() &&
          is_inline_piece(pieces[i - 1]) &&
          is_inline_piece(pieces[i + 1]) {
          out.push(Text(" "))
        }
    }
  }
  out
}

///|
fn is_inline_piece(piece : Piece) -> Bool {
  match piece {
    Literal(_) => true
    Gap => false
    Nested(node) => is_inline(node)
  }
}

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
/// it. Text, inline elements and control flow are. templ's rule is
/// `isInlineOrText`, and control flow is in it because a branch writes whatever
/// its own nodes write: the statement stands where inline content would, and each
/// branch is judged again on the nodes inside it. A component call is not inline,
/// even though it usually renders inline — nothing about the call says what it
/// produces, so a space next to one is kept only by the rules that name calls
/// outright. Neither is `{ children... }`, whose output the caller decides; templ
/// hands the whitespace after one to the list it stands in rather than to the
/// node, which is what `normalize_block_whitespace` reproduces.
pub fn is_inline(node : Node) -> Bool {
  match node {
    Text(_) | StringExpression(_) | If(_) => true
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
  /// `vertical` marks a run with a newline in it, which some of the rules below
  /// treat differently from a run that stays on one line.
  Gap(vertical~ : Bool)
  /// Any other node.
  Nested(Node)
}

///|
/// Normalize whitespace in a node list.
///
/// Whitespace inside a line of text is kept verbatim. A whitespace run that
/// starts a text node, or that contains a newline, becomes a single space where
/// `keeps_gap` says so and is dropped otherwise. That reproduces templ's rule of
/// consuming the whitespace that trails a node, while leaving the run that
/// precedes a tag inside the text itself.
pub fn normalize_whitespace(nodes : Array[Node]) -> Array[Node] {
  normalize(nodes, block=false, after=None)
}

///|
/// Normalize the nodes of a block body: the children of a component call, and the
/// branches of an `if`.
///
/// templ keeps every whitespace node of an element's children or a template body
/// but only the ones inside a block body, and the difference shows in the one
/// place a whitespace node comes from: `{ children... }` and an `if` do not take
/// the run after them the way every other node does, so that run is a node of the
/// list. In a block it is a space of its own — `@c() { { children... } x }`
/// renders `" x"` — while in an element or a template body it is dropped, so
/// `<p>{ children... } x</p>` renders `"x"`.
pub fn normalize_block_whitespace(nodes : Array[Node]) -> Array[Node] {
  normalize(nodes, block=true, after=None)
}

///|
/// `after` is the piece that follows this list, and it decides what the trailing
/// space of the list's last node comes to; `None` means the list ends the
/// template, the element or the block it belongs to, and there is nothing for
/// that space to separate it from.
fn normalize(
  nodes : Array[Node],
  block~ : Bool,
  after~ : Piece?,
) -> Array[Node] {
  let pieces : Array[Piece] = []
  for node in nodes {
    collect(node, pieces)
  }
  emit(resolve_bodies(pieces, block~, after~), block~, after~)
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
            children: normalize(e.children, block=false, after=None),
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
        out.push(Gap(vertical=has_newline(chars, split, j)))
      }
    }
    first = false
    i = j
  }
}

///|
fn has_newline(chars : Array[Char], from : Int32, to : Int32) -> Bool {
  for i = from; i < to; i = i + 1 {
    if chars[i] == '\n' {
      return true
    }
  }
  false
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
fn emit(pieces : Array[Piece], block~ : Bool, after~ : Piece?) -> Array[Node] {
  let out : Array[Node] = []
  for i, piece in pieces {
    match piece {
      Nested(node) => out.push(node)
      Literal(value) => out.push(Text(value))
      Gap(vertical~) =>
        if keeps_gap(pieces, i, vertical, block~, after~) {
          out.push(Text(" "))
        }
    }
  }
  out
}

///|
/// Whether the gap at `at` survives as a single space.
///
/// A run between two inline pieces is kept. A component call is not inline, so
/// it gets rules of its own: a self-closing call keeps the whitespace when text
/// follows it, and text keeps the whitespace when a self-closing call follows,
/// but only for a run on the same line — a call written on the next line is
/// laid out as a block and pulls no space after the text above it.
///
/// A run after a node that leaves it to the list is a whitespace node rather than
/// that node's trailing space. Inside the list only a block body writes one, as a
/// single space whatever stands next to it, a `<div>` included; at the end of the
/// list it is stripped, so the node before it has nothing to keep.
fn keeps_gap(
  pieces : Array[Piece],
  at : Int32,
  vertical : Bool,
  block~ : Bool,
  after~ : Piece?,
) -> Bool {
  if at == 0 {
    return false
  }
  let before = pieces[at - 1]
  if at + 1 >= pieces.length() {
    // The run that ends the list trails its last node, and templ decides that
    // node's trailing space against whatever follows the list: nothing at all
    // for a template body, an element's children or a call's block, and the
    // statement's next sibling for the branches of an `if`.
    if leaves_trailing_space_to_list(before) {
      return false
    }
    match after {
      Some(next) => keeps_trailing_space(before, next, vertical)
      None => false
    }
  } else if leaves_trailing_space_to_list(before) {
    block
  } else {
    keeps_trailing_space(before, pieces[at + 1], vertical)
  }
}

///|
/// Whether templ keeps the whitespace that trails `before` when `after` is what
/// stands on the other side of it.
fn keeps_trailing_space(before : Piece, after : Piece, vertical : Bool) -> Bool {
  if is_inline_piece(before) && is_inline_piece(after) {
    return true
  }
  if is_self_closing_call(before) && is_text_piece(after) {
    return true
  }
  if is_text_piece(before) && is_self_closing_call(after) {
    return !vertical
  }
  false
}

///|
/// The piece that follows the one at `at` once the list has been stripped: the
/// node a body standing at `at` judges its own last node's trailing space
/// against.
///
/// A whitespace node inside a block body survives and is therefore what stands
/// next, and being neither text nor an element it takes no space. Everywhere else
/// the whitespace nodes are dropped, the one at the end of a block included, and
/// then `after` — the piece that follows the list itself — is what stands next.
fn piece_after(
  pieces : Array[Piece],
  at : Int32,
  block~ : Bool,
  after~ : Piece?,
) -> Piece? {
  let mut i = at + 1
  while i < pieces.length() {
    match pieces[i] {
      Gap(_) => if block && i + 1 < pieces.length() { return Some(pieces[i]) }
      _ => return Some(pieces[i])
    }
    i = i + 1
  }
  after
}

///|
/// Normalize the bodies that need the list around them, which is what an `if` is:
/// its branches end where the statement's next sibling begins, so the last node
/// of each of them decides its trailing space against that sibling rather than
/// against nothing. templ hands `writeNodes` the very `next` node it was given
/// for the statement, and `piece_after` works out the same node here.
fn resolve_bodies(
  pieces : Array[Piece],
  block~ : Bool,
  after~ : Piece?,
) -> Array[Piece] {
  let out : Array[Piece] = []
  for i, piece in pieces {
    match piece {
      Nested(If(expr)) =>
        out.push(
          Nested(If(normalize_if(expr, piece_after(pieces, i, block~, after~)))),
        )
      _ => out.push(piece)
    }
  }
  out
}

///|
/// Every branch of an `if` is a block body written to the statement's next
/// sibling, `after`.
fn normalize_if(expr : IfExpression, after : Piece?) -> IfExpression {
  {
    condition: expr.condition,
    then: normalize(expr.then, block=true, after~),
    else_ifs: expr.else_ifs.map(fn(branch) {
      let next : ElseIf = {
        condition: branch.condition,
        then: normalize(branch.then, block=true, after~),
      }
      next
    }),
    else_: normalize(expr.else_, block=true, after~),
  }
}

///|
fn is_inline_piece(piece : Piece) -> Bool {
  match piece {
    Literal(_) => true
    Gap(_) => false
    Nested(node) => is_inline(node)
  }
}

///|
/// A piece that is text, or writes text: the two things a call keeps company
/// with. An element is neither, whatever it renders.
fn is_text_piece(piece : Piece) -> Bool {
  match piece {
    Literal(_) => true
    Nested(StringExpression(_)) => true
    Gap(_) | Nested(_) => false
  }
}

///|
/// A call with no children block. templ treats one as it treats text — standing
/// where text stands, it keeps its neighbouring space — with the single
/// exception `keeps_gap` weighs itself: text keeps a space before a call only
/// when the run between them stayed on one line.
fn is_self_closing_call(piece : Piece) -> Bool {
  match piece {
    Nested(Call(call)) => call.children.is_empty()
    _ => false
  }
}

///|
/// Whether the whitespace that follows this node belongs to the list it stands in
/// rather than to the node. templ gives the run after a node to the node itself
/// where the node can hold one — text, an element, an expression, a call — and
/// leaves it to the list where it cannot: an `if`, and a `{ children... }` whose
/// output the caller decides.
fn leaves_trailing_space_to_list(piece : Piece) -> Bool {
  match piece {
    Nested(If(_)) => true
    Nested(ChildrenExpression) => true
    _ => false
  }
}

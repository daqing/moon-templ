///|
/// Format a whole `.templ` file.
///
/// Only the `templ` blocks are rewritten; everything between them — comments,
/// imports, blank lines — is copied through as it stands. The parser records
/// where each block begins and ends for exactly this purpose, so a file that
/// carries notes its author wrote keeps them.
pub fn format_source(source : String) -> String raise @parser.ParseError {
  let file = @parser.parse_template_file(source)
  if file.templates.is_empty() {
    return source
  }
  let out = StringBuilder()
  let mut cursor = 0
  for template in file.templates {
    out.write_string(slice(source, cursor, template.start))
    out.write_string(format_template(template))
    cursor = template.end
  }
  out.write_string(slice(source, cursor, source.length()))
  out.to_string()
}

///|
/// The text of `source` between two UTF-16 offsets.
fn slice(source : String, from : Int32, to : Int32) -> String {
  match source[:].get_view(start=from, end=to) {
    Some(view) => view.to_owned()
    None => ""
  }
}

///|
/// Format one template block, from its `templ` keyword through its closing brace.
pub fn format_template(template : @parser.Template) -> String {
  let out = StringBuilder()
  out.write_string("templ ")
  if !template.receiver.is_empty() {
    out.write_char('(')
    out.write_string(template.receiver)
    out.write_string(") ")
  }
  out.write_string(template.name)
  out.write_char('(')
  out.write_string(template.params)
  out.write_string(") {\n")
  write_nodes(out, 1, template.nodes, false, None)
  out.write_char('}')
  out.to_string()
}

///|
fn write_indent(out : StringBuilder, level : Int32) -> Unit {
  for _ in 0..<level {
    out.write_string("  ")
  }
}

///|
/// Whether a node takes lines of its own. A statement always does, and so does
/// anything whose own source spelled a block or an indented attribute list out
/// over several lines. Everything else is written on the line it stands on.
fn is_vertical(node : @parser.Node) -> Bool {
  match node {
    If(_) | For(_) | Match(_) => true
    Call(call) => !call.children.is_empty()
    Element(element) =>
      element.indent_attrs ||
      (element.indent_children && !element.children.is_empty())
    RawElement(element) => element.contents.contains("\n")
    GoCode(code) => code.contains("\n")
    _ => false
  }
}

///|
/// A text node that holds nothing but whitespace. The parser turns the run that
/// trails a node into one of these, and whether it stays a space or is swallowed
/// by the line break that follows depends on what stands on either side of it.
fn is_blank_text(node : @parser.Node) -> Bool {
  match node {
    Text(value) => is_blank(value)
    _ => false
  }
}

///|
fn is_blank(value : String) -> Bool {
  let chars = value.to_array()
  for c in chars {
    if !is_space(c) {
      return false
    }
  }
  true
}

///|
fn is_space(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '\r' || c == '\n'
}

///|
fn trim_space(value : String) -> String {
  let chars = value.to_array()
  let len = chars.length()
  let mut start = 0
  let mut end = len
  while start < end && is_space(chars[start]) {
    start = start + 1
  }
  while end > start && is_space(chars[end - 1]) {
    end = end - 1
  }
  let out = StringBuilder()
  for i = start; i < end; i = i + 1 {
    out.write_char(chars[i])
  }
  out.to_string()
}

///|
/// Whether a node asks for a line of its own. A node that cannot stand beside
/// other nodes without a space appearing — anything the normalizer does not call
/// inline — does, and so does anything written over several lines.
fn wants_own_line(node : @parser.Node) -> Bool {
  is_vertical(node) || !@parser.is_inline(node)
}

///|
/// Write a node list.
///
/// The list is written one line at a time. Nodes share a line while neither side
/// asks for its own line and a line break would not change the whitespace the
/// nodes separate; where a line break would put a space between two inline nodes,
/// the two stay on one line, since the normalized tree has no space to spare for
/// it. `block` is whether this list is a block body, where a run that follows a
/// statement stays a space of its own; `after` is the node that follows the list
/// in its own list, which decides what a statement body's trailing space comes
/// to.
fn write_nodes(
  out : StringBuilder,
  level : Int32,
  nodes : Array[@parser.Node],
  block : Bool,
  after : @parser.Node?,
) -> Unit {
  let n = nodes.length()
  let mut i = 0
  while i < n {
    write_indent(out, level)
    let mut j = i
    let mut line_ends = false
    while !line_ends && j < n {
      let node = nodes[j]
      if is_blank_text(node) {
        // A list does not normally begin with whitespace, but a space the
        // normalizer kept can stand at the start of a line after a break it did
        // not come from; writing it keeps the output readable and reparses to
        // the same space.
        out.write_string(text_value(node))
        j = j + 1
        continue
      }
      write_node(out, level, node, next_after(nodes, j, after))
      let mut next = j + 1
      while next < n && is_blank_text(nodes[next]) {
        next = next + 1
      }
      if next >= n {
        // The end of the list: whatever whitespace trails it is written unless
        // the line break below already brings it back as a space.
        if !(blank_survives(Some(node), after, block, true) &&
          single_space(nodes, j + 1, next)) {
          write_blanks(out, nodes, j + 1, next)
        }
        j = next
        line_ends = true
      } else if wants_own_line(node) || wants_own_line(nodes[next]) {
        let has_blanks = next > j + 1
        let survives = blank_survives(
          Some(node),
          Some(nodes[next]),
          block,
          false,
        )
        if has_blanks && survives && single_space(nodes, j + 1, next) {
          // The line break recreates the space, so the space node is not written.
          j = next
          line_ends = true
        } else if has_blanks && !survives {
          // The space belongs to the line above; the break keeps it.
          write_blanks(out, nodes, j + 1, next)
          j = next
          line_ends = true
        } else if !has_blanks && break_is_safe(node, nodes[next], block) {
          j = next
          line_ends = true
        } else {
          // A break here would change the whitespace, so the next node stays on
          // this line.
          if has_blanks {
            write_blanks(out, nodes, j + 1, next)
          }
          j = next
        }
        // Neither node asks for a line of its own. A space between two nodes
        // that are not text is a line break in the making — that is how sibling
        // elements are laid out — while the spaces inside a phrase stay where
        // the words are.
      } else if next > j + 1 &&
        single_space(nodes, j + 1, next) &&
        !is_text_like(node) &&
        !is_text_like(nodes[next]) &&
        blank_survives(Some(node), Some(nodes[next]), block, false) {
        j = next
        line_ends = true
      } else {
        write_blanks(out, nodes, j + 1, next)
        j = next
      }
    }
    out.write_char('\n')
    i = if j > i { j } else { i + 1 }
  }
}

///|
/// Text, or something that writes text: the parts of a phrase that keep the
/// spaces around them.
fn is_text_like(node : @parser.Node) -> Bool {
  match node {
    Text(_) | StringExpression(_) => true
    _ => false
  }
}

///|
fn text_value(node : @parser.Node) -> String {
  match node {
    Text(value) => value
    _ => ""
  }
}

///|
/// Whether the whitespace run `[from, to)` is the single space the normalizer
/// turns a gap into.
fn single_space(nodes : Array[@parser.Node], from : Int32, to : Int32) -> Bool {
  to == from + 1 && nodes[from] is Text(" ")
}

///|
/// The node that follows the one at `at` in its list: the next one that carries
/// content, and when there is none, whatever follows the list itself.
fn next_after(
  nodes : Array[@parser.Node],
  at : Int32,
  after : @parser.Node?,
) -> @parser.Node? {
  let mut i = at + 1
  while i < nodes.length() {
    if !is_blank_text(nodes[i]) {
      return Some(nodes[i])
    }
    i = i + 1
  }
  after
}

///|
fn write_blanks(
  out : StringBuilder,
  nodes : Array[@parser.Node],
  from : Int32,
  to : Int32,
) -> Unit {
  for i = from; i < to; i = i + 1 {
    out.write_string(text_value(nodes[i]))
  }
}

///|
/// Whether a line break between two nodes can stand in place of no whitespace at
/// all: the parser must read the break back as nothing, not as a space.
fn break_is_safe(
  before : @parser.Node,
  after : @parser.Node,
  block : Bool,
) -> Bool {
  // A run after a statement is the list's own; only a block body keeps it, and
  // there it stays a space whatever the line break would do.
  if leaves_trailing_space_to_list(before) {
    return !block
  }
  !keeps_space(before, after)
}

///|
/// Whether a whitespace run between `before` and `next` comes back as a space
/// once the output is parsed again, with a line break in place of the run.
///
/// This mirrors the whitespace normalizer's rules: a run that ends a list is
/// dropped unless `after` stands on the other side of the statement the list
/// belongs to, and a run in the middle survives when the two nodes around it are
/// both inline.
fn blank_survives(
  before : @parser.Node?,
  next : @parser.Node?,
  block : Bool,
  at_end : Bool,
) -> Bool {
  let before = match before {
    Some(node) => node
    None => return false
  }
  if at_end {
    if leaves_trailing_space_to_list(before) {
      return false
    }
    match next {
      Some(node) => keeps_space(before, node)
      None => false
    }
  } else {
    if leaves_trailing_space_to_list(before) {
      return block
    }
    match next {
      Some(node) => keeps_space(before, node)
      None => false
    }
  }
}

///|
fn leaves_trailing_space_to_list(node : @parser.Node) -> Bool {
  match node {
    If(_) | For(_) | Match(_) | ChildrenExpression => true
    _ => false
  }
}

///|
fn keeps_space(before : @parser.Node, after : @parser.Node) -> Bool {
  if is_inline_piece(before) && is_inline_piece(after) {
    return true
  }
  if is_self_closing_call(before) && is_text_piece(after) {
    return true
  }
  if is_text_piece(before) && is_self_closing_call(after) {
    // A call written on a line of its own takes no space from the text above it.
    return false
  }
  false
}

///|
fn is_inline_piece(node : @parser.Node) -> Bool {
  if is_blank_text(node) {
    return false
  }
  @parser.is_inline(node)
}

///|
fn is_text_piece(node : @parser.Node) -> Bool {
  match node {
    Text(_) | StringExpression(_) => true
    _ => false
  }
}

///|
fn is_self_closing_call(node : @parser.Node) -> Bool {
  match node {
    Call(call) => call.children.is_empty()
    _ => false
  }
}

///|
fn write_node(
  out : StringBuilder,
  level : Int32,
  node : @parser.Node,
  after : @parser.Node?,
) -> Unit {
  match node {
    Element(element) => write_element(out, level, element)
    RawElement(element) => write_raw_element(out, level, element)
    Call(call) => write_call(out, level, call)
    If(expression) => write_if(out, level, expression, after)
    For(expression) => write_for(out, level, expression, after)
    Match(expression) => write_match(out, level, expression, after)
    GoCode(code) =>
      if code.contains("\n") {
        out.write_string("{{\n")
        out.write_string(code)
        out.write_char('\n')
        write_indent(out, level)
        out.write_string("}}")
      } else {
        out.write_string("{{ ")
        out.write_string(code)
        out.write_string(" }}")
      }
    _ => write_inline_node(out, level, node)
  }
}

///|
fn write_inline_node(
  out : StringBuilder,
  level : Int32,
  node : @parser.Node,
) -> Unit {
  match node {
    Text(value) => out.write_string(value)
    StringExpression(expression) =>
      out.write_string("{ " + trim_space(expression) + " }")
    ChildrenExpression => out.write_string("{ children... }")
    DocType(value) => out.write_string("<!DOCTYPE " + value + ">")
    HTMLComment(contents) => out.write_string("<!--" + contents + "-->")
    GoCode(code) => out.write_string("{{ " + code + " }}")
    Call(call) => write_call_inline(out, level, call)
    Element(element) => write_element(out, level, element)
    RawElement(element) => write_raw_element(out, level, element)
    If(_) | For(_) | Match(_) => write_node(out, level, node, None)
  }
}

///|
/// A call written on the line it stands on, which is how a call inside an
/// element whose children share its line is spelled.
fn write_call_inline(
  out : StringBuilder,
  level : Int32,
  call : @parser.Call,
) -> Unit {
  write_call_marker(out, call)
  if !call.children.is_empty() {
    out.write_string(" { ")
    for child in call.children {
      write_inline_node(out, level, child)
    }
    out.write_char('}')
  }
}

///|
fn write_call(out : StringBuilder, level : Int32, call : @parser.Call) -> Unit {
  write_call_marker(out, call)
  if !call.children.is_empty() {
    out.write_string(" {\n")
    write_nodes(out, level + 1, call.children, true, None)
    write_indent(out, level)
    out.write_char('}')
  }
}

///|
/// The call's `@` marker. A package-qualified expression kept its own `@` in
/// the parser because it doubles as the package reference, so it is written as
/// it stands rather than with a second marker.
fn write_call_marker(out : StringBuilder, call : @parser.Call) -> Unit {
  if call.expression.has_prefix("@") {
    out.write_string(call.expression)
  } else {
    out.write_char('@')
    out.write_string(call.expression)
  }
}

///|
fn write_if(
  out : StringBuilder,
  level : Int32,
  expression : @parser.IfExpression,
  after : @parser.Node?,
) -> Unit {
  out.write_string("if ")
  out.write_string(expression.condition)
  out.write_string(" {\n")
  write_nodes(out, level + 1, expression.then, true, after)
  for branch in expression.else_ifs {
    write_indent(out, level)
    out.write_string("} else if ")
    out.write_string(branch.condition)
    out.write_string(" {\n")
    write_nodes(out, level + 1, branch.then, true, after)
  }
  if !expression.else_.is_empty() {
    write_indent(out, level)
    out.write_string("} else {\n")
    write_nodes(out, level + 1, expression.else_, true, after)
  }
  write_indent(out, level)
  out.write_char('}')
}

///|
fn write_for(
  out : StringBuilder,
  level : Int32,
  expression : @parser.ForExpression,
  after : @parser.Node?,
) -> Unit {
  out.write_string("for ")
  out.write_string(expression.expression)
  out.write_string(" {\n")
  write_nodes(out, level + 1, expression.children, true, after)
  write_indent(out, level)
  out.write_char('}')
}

///|
fn write_match(
  out : StringBuilder,
  level : Int32,
  expression : @parser.MatchExpression,
  after : @parser.Node?,
) -> Unit {
  out.write_string("match ")
  out.write_string(expression.subject)
  out.write_string(" {\n")
  for arm in expression.arms {
    write_indent(out, level + 1)
    out.write_string(arm.pattern)
    out.write_string(" => {\n")
    write_nodes(out, level + 2, arm.children, true, after)
    write_indent(out, level + 1)
    out.write_string("}\n")
  }
  write_indent(out, level)
  out.write_char('}')
}

///|
fn write_element(
  out : StringBuilder,
  level : Int32,
  element : @parser.Element,
) -> Unit {
  out.write_char('<')
  out.write_string(element.name)
  if element.indent_attrs {
    for attr in element.attrs {
      out.write_char('\n')
      write_indent(out, level + 1)
      write_attribute(out, level + 1, attr, true)
    }
    out.write_char('\n')
    write_indent(out, level)
  } else {
    for attr in element.attrs {
      out.write_char(' ')
      write_attribute(out, level, attr, false)
    }
  }
  if element.children.is_empty() {
    if element.indent_children {
      out.write_string(">\n")
      write_indent(out, level)
      out.write_string("</")
      out.write_string(element.name)
      out.write_char('>')
    } else if element.self_closing {
      out.write_string("/>")
    } else if @parser.is_void_element(element.name) {
      out.write_char('>')
    } else {
      out.write_string("></")
      out.write_string(element.name)
      out.write_char('>')
    }
    return
  }
  if element.indent_children {
    out.write_string(">\n")
    write_nodes(out, level + 1, element.children, false, None)
    write_indent(out, level)
    out.write_string("</")
    out.write_string(element.name)
    out.write_char('>')
  } else {
    out.write_char('>')
    for child in element.children {
      write_inline_node(out, level, child)
    }
    out.write_string("</")
    out.write_string(element.name)
    out.write_char('>')
  }
}

///|
fn write_raw_element(
  out : StringBuilder,
  level : Int32,
  element : @parser.RawElement,
) -> Unit {
  out.write_char('<')
  out.write_string(element.name)
  for attr in element.attrs {
    out.write_char(' ')
    write_attribute(out, level, attr, false)
  }
  out.write_char('>')
  out.write_string(element.contents)
  out.write_string("</")
  out.write_string(element.name)
  out.write_char('>')
}

///|
/// Write one attribute. `indented` says its list sits on lines of its own, which
/// is where a conditional attribute opens its branches over several lines;
/// otherwise the whole conditional is written on the line it stands on, the way
/// a short one reads best.
fn write_attribute(
  out : StringBuilder,
  level : Int32,
  attr : @parser.Attribute,
  indented : Bool,
) -> Unit {
  match attr {
    Constant(name~, value~) =>
      if value.contains("\"") {
        out.write_string(name + "='" + value + "'")
      } else {
        out.write_string(name + "=\"" + value + "\"")
      }
    Expression(name~, value~) =>
      out.write_string(name + "={ " + trim_space(value) + " }")
    Bool(name~) => out.write_string(name)
    BoolExpression(name~, value~) =>
      out.write_string(name + "?={ " + trim_space(value) + " }")
    Spread(value~) => out.write_string("{ " + trim_space(value) + "... }")
    Conditional(condition~, then~, else_~) =>
      if indented {
        write_conditional_indented(out, level, condition, then, else_)
      } else {
        write_conditional_inline(out, level, condition, then, else_)
      }
  }
}

///|
fn write_conditional_indented(
  out : StringBuilder,
  level : Int32,
  condition : String,
  then : Array[@parser.Attribute],
  else_ : Array[@parser.Attribute],
) -> Unit {
  out.write_string("if ")
  out.write_string(trim_space(condition))
  out.write_string(" {\n")
  write_attribute_lines(out, level + 1, then)
  write_indent(out, level)
  out.write_char('}')
  if !else_.is_empty() {
    out.write_string(" else {\n")
    write_attribute_lines(out, level + 1, else_)
    write_indent(out, level)
    out.write_char('}')
  }
}

///|
fn write_attribute_lines(
  out : StringBuilder,
  level : Int32,
  attrs : Array[@parser.Attribute],
) -> Unit {
  for attr in attrs {
    write_indent(out, level)
    write_attribute(out, level, attr, true)
    out.write_char('\n')
  }
}

///|
fn write_conditional_inline(
  out : StringBuilder,
  level : Int32,
  condition : String,
  then : Array[@parser.Attribute],
  else_ : Array[@parser.Attribute],
) -> Unit {
  out.write_string("if ")
  out.write_string(trim_space(condition))
  out.write_string(" {")
  write_attributes_inline(out, level, then)
  out.write_string(" }")
  if !else_.is_empty() {
    out.write_string(" else {")
    write_attributes_inline(out, level, else_)
    out.write_string(" }")
  }
}

///|
fn write_attributes_inline(
  out : StringBuilder,
  level : Int32,
  attrs : Array[@parser.Attribute],
) -> Unit {
  for attr in attrs {
    out.write_char(' ')
    write_attribute(out, level, attr, false)
  }
}

///|
pub struct RenderCtx {
  children : Component
  nonce : String
}

///|
pub struct Component {
  priv render_fn : (RenderCtx, &Logger) -> Unit
}

///|
pub fn component(render : (RenderCtx, &Logger) -> Unit) -> Component {
  { render_fn: render, }
}

///|
pub fn RenderCtx::new() -> RenderCtx {
  { children: Component::nop(), nonce: "", }
}

///|
pub fn RenderCtx::clear_children(self : RenderCtx) -> RenderCtx {
  { children: Component::nop(), nonce: self.nonce, }
}

///|
pub fn RenderCtx::with_children(
  self : RenderCtx,
  children : Component,
) -> RenderCtx {
  { children, nonce: self.nonce, }
}

///|
pub fn Component::nop() -> Component {
  component(fn(_ctx, _w) {  })
}

///|
pub fn Component::render(
  self : Component,
  ctx : RenderCtx,
  w : &Logger,
) -> Unit {
  (self.render_fn)(ctx, w)
}

///|
pub fn Component::with_children(
  self : Component,
  children : Component,
) -> Component {
  component(fn(ctx, w) { self.render(ctx.with_children(children), w) })
}

///|
pub impl Show for Component with fn output(self, logger) {
  self.render(RenderCtx::new(), logger)
}

///|
pub extend Component with Show::{to_string, output}

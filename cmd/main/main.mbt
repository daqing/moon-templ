///|
/// The `moon-templ` entry point. `@env.args()` carries the executable first, so
/// it goes straight to `@cli.run` as it arrives; everything else lives in
/// `cli/`, where it can be tested without a process.
fn main {
  @sys.exit(@cli.run(@env.args()))
}

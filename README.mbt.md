# moon-templ

A MoonBit port of [templ](https://templ.guide/). Components are written in
plain `.templ` files, generated into ordinary MoonBit functions, and checked in —
no macros and no runtime template parsing.

## Installation

Add the module to your project:

```bash
moon add daqing/moon-templ
```

Build the command-line tool from a checkout of this repository and put it on
your `PATH`:

```bash
moon build --target native cmd/moon-templ
install -m 755 _build/native/debug/build/cmd/moon-templ/moon-templ.exe /usr/local/bin/moon-templ
```

## Quick start

Write `hello.templ`:

```templ
templ hello(name : String) {
  <div class="greeting">Hello, { name }!</div>
}
```

Generate the MoonBit file:

```bash
moon-templ generate hello.templ
# generated hello_templ.mbt
```

Give the package the runtime, and keep `moon fmt` out of the generated file:

```
import {
  "daqing/moon-templ/runtime" @rt,
}

formatter(ignore: [ "hello_templ.mbt" ])
```

The alias must be `@rt`, because that is how the generated code refers to the
runtime. The `ignore` list takes exact file names — no globs.

Then call the component like any function:

```moonbit nocheck
///|
fn main {
  println(hello("world").to_string())
}
```

```
<div class="greeting">Hello, world!</div>
```

## Template syntax

- `{ expression }` inserts escaped text. `{ children... }` renders the children
  the caller handed to the component.
- Attributes may be constant, computed, boolean, spread, or decided by an `if`:

  ```templ
  templ card(title : String, id : String, locked : Bool, dark : Bool, attrs : @rt.Attributes) {
    <article class="card" data-id={ id } disabled?={ locked } { attrs... }
      if dark { data-theme="dark" } else { data-theme="light" }>
      <h2>{ title }</h2>
      { children... }
    </article>
  }
  ```

- Control flow uses MoonBit's own forms:

  ```templ
  if ok {
    <p>ready</p>
  } else if retrying {
    <p>trying again</p>
  } else {
    <p>stopped</p>
  }

  for item in items {
    <li>{ item }</li>
  }

  for i = 0; i < count; i = i + 1 {
    <span>{ i }</span>
  }

  match kind {
    Some(v) => {
      <em>{ v }</em>
    }
    _ => {
      <em>none</em>
    }
  }
  ```

- Components are called with `@`: `@card(title)`, `@card(title) { ... }`, and
  `@ui.card(...)` for another package. A parameter of type `@rt.Component` is
  rendered with `@child`.
- `<style>` and `<script>` keep their contents verbatim, so JavaScript and CSS
  are not read as template syntax. `<!-- comments -->`, `<!DOCTYPE html>`, and
  `{{ MoonBit code }}` blocks holding statements are supported as well.

## Commands

```
moon-templ generate <file.templ>
moon-templ generate <dir>...      # or a bare directory
moon-templ generate --watch <dir>...
moon-templ fmt <file.templ>       # or <dir>...
```

- A generated file is rewritten only when its content changes, and `generate`
  refuses to overwrite a file that does not carry the generated header.
- Syntax errors are reported as `file:line:column: message`.
- `fmt` rewrites only the `templ` blocks; comments and the text between blocks
  are left as they stand. Formatting an already formatted file changes nothing.
- `--watch` regenerates templates as they change, polling every 250 ms. It needs
  a clock, which only the native target offers: use the installed binary, or
  `moon run --target native cmd/moon-templ -- generate --watch ...`.

## Build integration

Commit the generated files — the same model as templ. Generation is run by hand
or from a pre-commit hook, and `moon build` needs nothing beyond the runtime
import and `formatter(ignore: [...])`.

To generate during the build instead, declare the template as an input in the
package's `moon.pkg`:

```
rule(
  name: "templ",
  command: "moon-templ generate $input",
)

dev_build(
  rule: "templ",
  input: "hello.templ",
  output: "hello_templ.mbt",
)
```

The command runs at the module root with `$input` as the module-relative path;
`input` and `output` are written relative to the package. The rule runs again
only when the input changes. `input` cannot be a directory or a glob, so each
template needs its own `dev_build`. This form cannot be combined with the older
`pre-build` option in the same package.

`moon-templ` must be on `PATH`, or give its absolute path in `command`. Keep
`formatter(ignore: [...])` for every generated file either way.

## Differences from templ

| templ | moon-templ |
|---|---|
| Go | MoonBit |
| `switch` / `case` | `match` with MoonBit patterns: `Some(v) => { ... }`, `_ => { ... }` |
| `for i, v := range items` | `for v in items`; C-style `for i = 0; i < n; i = i + 1 { ... }` also works |
| `{{ go code }}` | `{{ MoonBit code }}`, copied into the generated function body |
| `templ Name()` with any Go name | The template becomes a MoonBit function, so its name must start with a lowercase letter or `_` |
| `templ (t T) Name()` | The same receiver syntax, with the same naming rule |
| `@Component()` / `@pkg.Component()` | `@component()` for a sibling, `@pkg.component(...)` for another package |
| `_templ.go` | `_templ.mbt` |
| `templ generate --watch` with a live-reload proxy | `--watch` only regenerates; native target only |
| `script` declarations and `RenderScriptItems` | Not implemented yet; `<script>` elements are kept verbatim and `@rt.ComponentScript` renders a call string |

Expressions and attributes are MoonBit expressions, so the MoonBit compiler
checks them instead of a separate expression parser.

## Development

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt
moon info
```

Packages: `parser/` (`.templ` to AST), `generator/` (AST to MoonBit), `runtime/`
(rendering and escaping), `formatter/` (AST back to `.templ`), `cli/` (the
command), and `cmd/moon-templ/` (the entry point). Examples live in `examples/`, and
the ported templ goldens in `golden/`.

## License

Apache-2.0.

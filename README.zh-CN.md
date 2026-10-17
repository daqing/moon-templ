# moon-templ

[templ](https://templ.guardian.io/) 的 MoonBit 移植版。组件写在普通的 `.templ`
文件里,生成成普通的 MoonBit 函数后提交进仓库 —— 没有宏,也不在运行时解析模板。

## 安装

把模块加入你的项目:

```bash
moon add daqing/moon-templ
```

从本仓库的检出构建命令行工具,并放进 `PATH`:

```bash
moon build --target native cmd/main
install -m 755 _build/native/debug/build/cmd/main/main.exe /usr/local/bin/moon-templ
```

## 快速上手

编写 `hello.templ`:

```templ
templ hello(name : String) {
  <div class="greeting">Hello, { name }!</div>
}
```

生成 MoonBit 文件:

```bash
moon-templ generate hello.templ
# generated hello_templ.mbt
```

给包加上运行时依赖,并让 `moon fmt` 跳过生成的文件:

```
import {
  "daqing/moon-templ/runtime" @rt,
}

formatter(ignore: [ "hello_templ.mbt" ])
```

别名必须是 `@rt`,生成代码正是用这个名字引用运行时。`ignore` 列表只接受确切的
文件名,不支持通配符。

然后像普通函数一样调用组件:

```moonbit nocheck
fn main {
  println(hello("world").to_string())
}
```

```
<div class="greeting">Hello, world!</div>
```

## 模板语法

- `{ expression }` 插入转义后的文本;`{ children... }` 渲染调用方传给组件的子内容。
- 属性可以是常量、表达式、布尔值、展开,或由 `if` 决定:

  ```templ
  templ card(title : String, id : String, locked : Bool, dark : Bool, attrs : @rt.Attributes) {
    <article class="card" data-id={ id } disabled?={ locked } { attrs... }
      if dark { data-theme="dark" } else { data-theme="light" }>
      <h2>{ title }</h2>
      { children... }
    </article>
  }
  ```

- 控制流直接使用 MoonBit 的写法:

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

- 组件用 `@` 调用:`@card(title)`、`@card(title) { ... }`;其他包里的组件写作
  `@@ui.card(...)`。类型为 `@rt.Component` 的参数用 `@child` 渲染。
- `<style>` 和 `<script>` 的内容原样保留,JavaScript 与 CSS 不会被当成模板语法。
  `<!-- comments -->`、`<!DOCTYPE html>` 以及存放语句的 `{{ MoonBit code }}`
  代码块同样受支持。

## 命令

```
moon-templ generate <file.templ>
moon-templ generate <dir>...      # 也可以直接给目录
moon-templ generate --watch <dir>...
moon-templ fmt <file.templ>       # 或 <dir>...
```

- 生成文件只在内容变化时才重写;如果目标文件不带生成头,`generate` 会拒绝覆盖。
- 语法错误按 `file:line:column: message` 报告。
- `fmt` 只重写 `templ` 块;注释和块之间的文本保持原样。对已经格式化过的文件执行
  格式化不会产生任何改动。
- `--watch` 在模板变化时重新生成,每 250 毫秒轮询一次。它需要时钟,而只有 native
  目标提供时钟:请使用安装好的可执行文件,或运行
  `moon run --target native cmd/main -- generate --watch ...`。

## 构建集成

**把生成文件提交进仓库** —— 与 templ 相同的模式。生成由手工执行,或交给
pre-commit hook;`moon build` 除了运行时导入和 `formatter(ignore: [...])`
之外不需要任何额外配置。

如果要在构建过程中生成,就在包的 `moon.pkg` 里把模板声明为输入:

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

命令在模块根目录执行,`$input` 是模块相对路径;`input` 和 `output` 则相对于包
书写。只有输入变化时这条规则才会重新执行。`input` 不能是目录或通配符,所以每个
模板都需要一条自己的 `dev_build`。这种写法不能与同一个包里旧的 `pre-build`
选项混用。

`moon-templ` 必须在 `PATH` 上,或者在 `command` 里写出绝对路径。无论用哪种方式,
每个生成文件都要保留 `formatter(ignore: [...])`。

## 与 templ 的差异

| templ | moon-templ |
|---|---|
| Go | MoonBit |
| `switch` / `case` | 用 MoonBit 模式写 `match`:`Some(v) => { ... }`、`_ => { ... }` |
| `for i, v := range items` | `for v in items`;C 风格的 `for i = 0; i < n; i = i + 1 { ... }` 也可以用 |
| `{{ go code }}` | `{{ MoonBit code }}`,原样抄进生成的函数体 |
| `templ Name()`,Go 里可任意命名 | 模板会变成 MoonBit 函数,名字必须以小写字母或 `_` 开头 |
| `templ (t T) Name()` | receiver 写法相同,命名规则也相同 |
| `@Component()` / `@pkg.Component()` | 同包用 `@component()`,其他包用 `@@pkg.component(...)` |
| `_templ.go` | `_templ.mbt` |
| 带 live-reload 代理的 `templ generate --watch` | `--watch` 只负责重新生成,且仅支持 native 目标 |
| `script` 声明与 `RenderScriptItems` | 尚未实现;`<script>` 元素原样保留,`@rt.ComponentScript` 只渲染调用字符串 |

表达式和属性都是 MoonBit 表达式,由 MoonBit 编译器检查,不需要单独实现一个表达式
解析器。

## 开发

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt
moon info
```

包的结构:`parser/`(`.templ` 到 AST)、`generator/`(AST 到 MoonBit)、`runtime/`
(渲染与转义)、`formatter/`(AST 还原为 `.templ`)、`cli/`(命令)以及
`cmd/main/`(入口)。示例在 `examples/`,从 templ 移植过来的基准用例在 `golden/`。

## 许可证

Apache-2.0。

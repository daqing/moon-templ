# moon-templ 实施任务清单

配套文档:[port-research.md](./port-research.md)(可行性调研与设计依据)
拆分日期:2026-10-17
目标:把 `a-h/templ` 的模板引擎在 MoonBit 中重新实现

**进度:51 / 58**

---

## 怎么用这份清单

- **每个任务前的复选框就是进度表。** 任务完成时把 `[ ]` 改成 `[x]`,并同步更新顶部的进度计数。**这一步是自动的** —— 每完成一个任务,当即打钩,不要攒着事后补。
- **任务粒度按"闲余时间一次坐下能完成"来切**,规模标注:S ≈ 1 小时内,M ≈ 2–3 小时,L ≈ 半天以上(建议再拆)。各阶段汇总:

  | 阶段 | 任务数 | 已完成 | 剩余 L |
  |---|---|---|---|
  | T0 决策与准备 | 5 | 5 | 0 |
  | T1 runtime 地基 | 5 | 5 | 0 |
  | T2 parser + generator 骨架 | 19 | 19 | 0 |
  | T3 MVP 完整 | 11 | 11 | 0 |
  | T4 属性特殊语义 | 8 | 8 | 0 |
  | T5 工具链与打磨 | 5 | 3 | 1(T5.4) |
  | T6 可选 / 远期 | 5 | 0 | 3 |

- **每个任务独立可交付。** commit message 以任务号开头,例如 `T2.3: parse element open/close tags`。
- **任何一步做完,仓库必须保持绿色**(`moon check` + `moon test` 通过)。宁可任务不做完,不要留半截的坏状态。
- **提交在 `develop` 分支上做**,不要直接在 `main` 上提交。
- 拿不准选哪个任务时,挑**规模 S 且前置已满足**的;L 的任务留到有整块时间时做。

---

## Phase 0 — 决策门与工程准备

**T0.1 – T0.4 是决策门**,已于 2026-10-17 全部拍板,结论写回 `port-research.md` §8 与 §4。

- [x] **T0.1** 控制流语法 → **用 MoonBit 原生 `match`**,不用 Go 风格 `switch` · S
- [x] **T0.2** 产物策略 → **生成产物提交进仓库**(照搬 templ 的 `_templ.go` 模式),`pre-build` 作为可选便利功能 · S
- [x] **T0.3** 错误模型 → **无 `raise`**,签名 `(RenderCtx, &Logger) -> Unit`;换来 `impl Show` 可用 · S
- [x] **T0.4** 扩展名 → **沿用 `.templ`**,便于对照 templ 文档与迁移 · S
- [x] **T0.5** 建仓库骨架:`runtime/` `parser/` `generator/` 三个包 + 各自 `moon.pkg` — `moon check` 通过,`moon run cmd/main` 能打印 · S

---

## Phase 1 — runtime 地基

> 已全部完成,落在 `runtime/`,11 个单测通过、零警告。实现中的发现见 `port-research.md` §3.1 / §3.2。

- [x] **T1.1** `Component` / `RenderCtx` / `component()` / `with_children` / `clear_children` — 单测:嵌套两层组件,children 传到正确的那一层 · 前置 T0.3、T0.5 · S
- [x] **T1.2** `escape` 固定转义表 + `write_escaped` — 单测覆盖 `&` `'` `<` `>` `"` 五条,逐字节比对 · 前置 T1.1 · S
- [x] **T1.3** `write_any[T : Show]` 泛型输出 + `raw()` — 单测:`String`/`Int`/`Double`/`Bool`;`raw` 不转义 · 前置 T1.2 · S
- [x] **T1.4** `impl Show for Component` + `extend Component with Show::{to_string, output}` — `moon check` 无 `implicit_impl_as_method` 警告 · 前置 T1.3 · S
- [x] **T1.5** runtime 边界测试补齐 — 空串、多字节 UTF-8、已是实体的输入(会再转义)、超长输入 · 前置 T1.4 · S

---

## Phase 2 — parser + generator 骨架(打通 M1)

> 本阶段的唯一目标:让**最简单的模板**端到端跑起来。有了这条"行走骨架",后面每个特性都是往已知结构里填空。

- [x] **T2.1** AST 定义 `parser/types.mbt` — `Node`/`Element`/`Attribute`/`Template`/`TemplateFile`,全 `pub(all)` + `derive(Debug, Eq)`;黑盒测试验证跨包构造可用 · 前置 T0.5 · M
- [x] **T2.2** `{ expr }` 花括号配平扫描器 `parser/expression.mbt` — 嵌套 `()` `[]` `{}` 正确;字符串(含转义)、rune、行/块注释内的 `}` 均不误判;未闭合报 `ParseError` · 前置 T2.1 · M
- [x] **T2.3** 文本节点 + 元素开闭标签解析(`parser/element.mbt`)— 单测:`<div></div>`、自闭合、void 元素、嵌套、大小写、元素名 charset、属性值内的 `>`;顺带把 `{ expr }` 收成 `StringExpression` 节点(否则文本循环会空转) · 前置 T2.2 · M
- [x] **T2.4** 属性解析 v1:静态 `name="v"`、三种引号、裸布尔属性(`parser/attribute.mbt`)— 单测覆盖 `"` `'` 无引号三种形式、空值、名字 charset(`@click` `:class` `x-on:click`)。`name={ expr }` 与 `name?={ expr }` 显式报"暂不支持",留 T3.1 / T4.7 · 前置 T2.3 · M
- [x] **T2.5** 空白归一化 v1(块级元素判定 + 折叠,`parser/whitespace.mbt`)— 规则从 templ 自己的 parser+generator 反推,并用 **748 组差分用例**对齐(`parser/whitespace_golden_test.mbt`,由 Go 探针生成)。规则与反例见 port-research §3.6 · 前置 T2.3 · M
- [x] **T2.6** 文件级切分:`templ` 块识别 + 签名抽取(`parser/template.mbt`)— 单测:无参、带参、方法形式;签名用"扫描到 depth-0 `{`"取原文。`Template` 增设 `receiver` 字段承接 `templ (self : T) Name()` 形式 · 前置 T2.1 · M
- [x] **T2.7** `RangeWriter` 两态写入(累积字面量 vs 写代码,`generator/rangewriter.mbt`)— 单测:连续文本合并成**一个** `write_string`;字面量按全文件顺序记录在 `literals()`。**下标不写进产物**(runtime 不需要),差异记在 port-research §6 · 前置 T0.5 · M
- [x] **T2.8** 字面量生成:MoonBit 字符串转义(`generator/literal.mbt` 的 `string_literal`)— 单测:含 `"` `\` 换行 tab 控制符的文本。**`String::escape()` 自带首尾引号,别再包一层**;期望值直接写成 MoonBit 源码文本,由编译器替我们验证它确实是合法字面量 · 前置 T2.7 · S
- [x] **T2.9** generator 骨架:`Generator` 结构 + 变量名计数器 + 组件函数头尾发射(`generator/generator.mbt`)— 对**空组件**产出可编译骨架;产物文本已实测能通过 `moon check`(零警告)且 `moon fmt` 幂等。字面量下标改由 `RangeWriter` 持有(见 T2.7),不再单设计数器;`templ (self : T) Name()` 生成 `pub fn T::Name(...)` · 前置 T2.6 · M
- [x] **T2.10** 节点分派表:AST 节点 → 各 handler 的有序分派 — 未实现的节点类型报**明确的**错误(带节点名与位置),不是静默跳过 · 前置 T2.9 · S
  - 分派是 `match` 穷尽 `@parser.Node`,新增节点类型会**编译期**要求在此做出选择,不会静默漏掉;未实现的类型报 `cannot generate an element node yet (in template \`b\`)`。
  - 位置暂时只有模板名:AST 尚未携带源码位置(T5.1 补),节点下标要等有节点真正发射出来(T2.11)才有意义,届时一并加上。
  - 顺带修正 `RangeWriter::write_literal` 的缩进语义:层级随字面量走,而不是跟着触发 flush 的那行代码 —— 否则模板体末尾的那段字面量会被闭合花括号带到外一层缩进。
- [x] **T2.11** 字面量发射:把 `RangeWriter` 接进 generator — 单测:`<div>` + 文本 + `<span>` 合并成**一个** `write_string`,不是三次 · 前置 T2.7、T2.8、T2.9 · M
  - 文本、HTML 注释、doc type 三类节点都走 `RangeWriter`,相邻字面量自然并成一句 `w.write_string`;已实测生成物可编译并渲染出正确 HTML(`<!doctype html><!-- a page -->hi`)。
  - 偏差:任务里写的是 `<div>`+文本+`<span>` 合并,但元素节点要等 **T2.12**;当前用 `Text` + `HTMLComment` + `Text` 三种相邻节点验证合并,元素版本挪到 T2.12 一起补。
- [x] **T2.12** 元素节点发射:起止标签、自闭合、void 元素 — 单测:`<div></div>` / `<br/>` / `<img src="x">` 三种产物都正确。**同时补 T2.3 留下的缺口:裸文本元素** `<>` `<text>` `<style>` `<script>`,其内容不按标签/表达式解析(T2.3 目前会把 `<style>a>b{}</style>` 误解析)· 前置 T2.3、T2.11 · M
  - 元素与属性都走字面量缓冲,`<div class="a">Hello, <span>world</span></div>` 整段并成**一句** `w.write_string`(即 T2.11 欠下的那半个用例,现已补上)。
  - 新增 `RawElement` 节点承接 `<style>`/`<script>`:内容原样收进 `contents`,既不解析标签也不解析 `{ expr }`,空白归一化也跳过它(否则 CSS/JS 里的空白会被折叠掉)。
  - **偏差一**:任务里写的 `<text>` 与 `<>` 在 templ v0.3.1070 中**并不存在** —— 源码那行的注释是过时的,实际注册的是 `parse.Any(styleElement, scriptElement)`。已把勘误记进 port-research §1.1,只实现 `<style>`/`<script>`。
  - **偏差二**:`<script>` 暂时按 `rawElementParser` 的朴素做法扫到 `</script>`;templ 对 `type` 是 JS 的 `<script>` 另有 JS 字符串/注释感知的扫描器(`parser/v2/scriptparser.go`,约 200 行),留到后续任务。
  - **偏差三**:`Attribute.Constant` 没有保留源码引号(T2.4 未记录),生成时统一用 `"`,仅当值里真的含 `"` 时退化成 `'`,以免生成出坏 HTML。
- [x] **T2.13** 表达式节点发射:`{ expr }` → `@rt.write_any(w, expr)` — 单测:`Hello, { name }` 产物是**两段字面量夹一次** `write_any` · 前置 T2.2、T2.11、T1.3 · M
  - 表达式是代码,写出它即结束当前字面量连续段,所以 `Hello, { name }!` 是 `write_string` / `write_any` / `write_string` 三句:实测产物可编译、可渲染,`greet("<b>&\"x", 0)` → `&lt;b&gt;&amp;&#34;x`(转义由 T1.3 的运行时负责)。
  - 表达式原文 **trim 后逐字抄进产物**,不做任何解析或改写 —— 语法正确性交给 MoonBit 编译器,出错位置也落在产物里那一行。
  - **多值表达式 `{ a, b }` 暂不支持**(port-research §8 已定的 MVP 范围):templ 用变参的 `JoinStringErrs` 拼接,templ 侧要支持得先决定 MoonBit 侧的拼接语义。现在**明确报错**而不是生成一个参数个数不对的调用;判据是 parser 新增的 `holds_multiple_values`(只在顶层、括号/字符串/rune/注释之外数逗号),`{ f(a, b) }` 与 `{ "a, b" }` 仍算单值。
  - `{ }`/`{   }` 与 templ 一致:**什么都不写**(templ 的 `writeStringExpression` 对空白表达式直接 return)。副作用是 `templ t() { { } }` 的产物里 `w` 未被使用,会触发 `unused_value`,归到 T2.16 一并定案。
  - 顺带把 `RangeWriter` 的字面量层级改成"取该连续段跨越的**最外层**层级":否则一段从元素内部开始、一路吸收到该元素闭合标签的字面量,会按子节点的层级缩进,与上下文的标签对不齐(产物见 `_scratch` 实测)。
- [x] **T2.14** CLI 骨架:`moon-templ generate <file.templ>` 单文件 — 产出 `x_templ.mbt`。注意 `args[0]` 是构建产物路径,真实参数从 `args[1]` 起 · 前置 T2.13 · M
  - 逻辑落在新包 **`cli/`**,`cmd/main` 只剩一行 `@sys.exit(@cli.run(@env.args()))` —— 命令行解析、读写文件、出错提示都在库里,测试不必起进程(T2.15 的集成测试要靠这个)。
  - 新增依赖 **`moonbitlang/x@0.5.5`**(`@fs` 读写文件、`@sys.exit` 退出码),正是 port-research 里为 CLI 定好的方案。**踩到的坑:core 里没有任何公开的退出接口**(`argparse` 的 `runtime_exit_*` 是私有的),`fn main` 又必须返回 `Unit`;用 `fn main raise` 让错误冒出去也不行 —— 实测 wasm 下只报 `RuntimeError: unreachable`、native 下打一串 panic 回栈且退出码是 134。所以错误一律自己 `eprintln` + 返回退出码,退出码只能从 `@sys.exit` 走。
  - 用法错(`generate` 缺参数、多参数、未知子命令)与运行期错(读不到文件、解析失败)都返回 **1**,提示打到 stderr;`eprintln` 在 prelude 里,不必额外引入。
  - **防覆盖**:产物路径已存在时,只有以 `// Code generated by moon-templ. DO NOT EDIT.` 开头的文件才允许重写,否则报 `was not generated by moon-templ, refusing to overwrite it` —— 手写文件被同名的 `x_templ.mbt` 撞上时不会丢。该 header 由 generator 新增的 `generated_header()` 统一给出,两处不重复字面量。
  - 偏差:`generate_file` 的文件读写路径(含防覆盖分支)靠手工实测,单测只覆盖 `output_path` 与 `run` 的参数分支 —— 往仓库里写临时文件会留垃圾,文件往返留给 T2.15 的端到端用例。
- [x] **T2.15** **端到端 M1**:手写 `examples/hello/hello.templ` 全链路跑通 — 生成 → `moon build` → 运行 → HTML 输出逐字节正确;写成可重复执行的集成测试 · 前置 T2.14 · S
  - `examples/hello/` 是一个可执行包:`hello.templ`(手写)+ `hello_templ.mbt`(**已提交**的产物)+ `main.mbt`(打印渲染结果)+ `hello_wbtest.mbt`(断言逐字节相等,白盒测试在可执行包里可用)。产物入库是有意的:新克隆不跑生成器也能 `moon build` / `moon run`。
  - 全链路实测(把产物先移走再走一遍):产物缺失时 `moon build` 失败 → `moon run cmd/main -- generate examples/hello/hello.templ` → `moon build` 通过 → `moon run examples/hello` 打出 `<div class="greeting">Hello, world!</div>`。
  - **漂移护栏** `cli/example_wbtest.mbt`:读回 `.templ` 与已提交的产物、比对,而**不是**原地重新生成 —— 原地重写在有漂移时会把文件"顺手修好",测试反而永远绿。已实测:手动往产物里塞一行,护栏立刻变红。
  - **关键发现:`moon fmt` 会把一个块里的语句全部对齐到块自身的层级**,所以在产物里按元素深度缩进是白费功夫,格式化一次就被抹平(实测:格式化和未格式化的产物差的就是 `@rt.write_any` 那一行的缩进)。据此把 `write_element` 的子节点改回与父同级 —— **只有块**(模板体、以后的 `if`/`for`)才推层级,HTML 标签不推。T2.13 顺带加进 `RangeWriter` 的"取最外层层级"规则是在给更深的缩进打补丁,一并撤回。
  - 结果:生成的产物在 `moon fmt` 下保持不变(已用 `diff` 实测)。**但这个结论只对 `examples/hello` 这种短行产物成立** —— T2.19 实测 `moon fmt` 会折行超过 80 列的语句,长字面量或长表达式的产物照样被重排;正式做法是 `formatter(ignore: [...])`(见 T2.19 与 port-research §6.1)。
  - 记录:`moon test` 的工作目录是**模块根**,不是包目录,所以测试里的路径写成 `examples/hello/hello.templ` 这种模块根相对路径。
- [x] **T2.16** 生成后内联 `@fmt.format` 规范化产物 — 产物格式规范、`///|` 块分隔齐全(port-research §6)。**同时定案 `unused_value` 的产物侧对策**:未使用的模板参数、以及只写空表达式(`{ }`)导致 `w` 没被用到的模板,产物不能带警告 · 前置 T2.15 · S
  - **`@fmt.format` 内联:实测后决定不做,偏差已记入 port-research §6.1。** 证据:临时加上 `moonbitlang/parser@0.4.5` 后,`@fmt.format(generated.source)` 会把产物改成另一种版式(`@rt.component(` 的闭包参数独占一行并带尾逗号、文件开头的空行挪到注释之前),而 `moon fmt` 又把它**改回我们现在的版式**(把 `@fmt.format` 的产物落盘后跑 `moon fmt`,再与产物 `diff` —— 完全一致)。也就是说这条链上的 `@fmt.format` 比工具链里的 `moon fmt` 旧,内联它等于主动生成一个 `moon fmt` 立刻要重写的文件,还会当场把 T2.15 的漂移护栏弄红。另外 `moonbitlang/parser/fmt` 自己的 README 标着 "highly experimental and work in progress",注释与空行两项状态未打勾,依赖树也不小(x、lexer、moon_config、async、prettyprinter)。**采纳的判据是"产物贴着 `moon fmt` 的版式写"**,而不是"产物经过某个 formatter";`///|` 分隔由 `write_template` 自己发。**但"产物是 `moon fmt` 的不动点"这个更强的说法是错的,T2.19 已实测更正**(`moon fmt` 折行超过 80 列的行,而抄进产物的表达式长度由用户决定)。
  - **`unused_value` 定案**:未使用的参数与接收者在闭包体开头 `ignore(x)` —— 签名由模板作者决定,不能因为体里没读就删,`ignore` 保住调用点的具名写法;`ignore` 一个其实被用到的名字零代价,所以判不准时一律算"被用到",最坏是多一条警告而不会让体坏掉。`~name` 这类带标签(以及任何非平凡标识符)的参数**跳过不动**:调用点怎么拼是调用者的事,生成器不能替他改。体不产生任何输出时,写游标参数直接叫 `_w` 而不是 `w` + `ignore(w)`(空体的产物因此更短:一次 `@rt.component(fn(_ctx, _w) {  })`)。
  - "体里有没有读这个参数"的判据是**只在 `StringExpression` 里搜**(元素递归下去),文本节点不算 —— `<p>name</p>` 里的 `name` 是给用户看的字,不是读参数。匹配按**整词**边界(`mentions`),否则参数 `a` 会被 `ab` 误判成已用。
  - 结果:三个原先各带一条 `unused_value` 警告的模板全部无警告;generator 包 57 个测试、全模块 154 个测试通过。
- [x] **T2.17** 解析 `<!doctype html>` 与 `<!-- ... -->`(parser 侧)— T2.11 已经能**发射**这两类节点,但 parser 一个都产生不出来,现在只能从手搭 AST 测;不加这段,真实页面里的 doctype 会直接报"element name must start with a lowercase letter: !"。同时给 T2.11 的 `HTMLComment` 内容定案:templ 的 `Contents` **不含** `<!--`/`-->`,只有中间那段 · 前置 T2.4 · S
  - 新增 `parser/declaration.mbt`,并在 `element.mbt` 里把 `['<', ..]` 这一支提成 `parse_tag`:注释 → doctype → raw element → 普通元素。这两类必须排在 `parse_element` **之前**,否则 `<!` 会先撞上"element name must start with a lowercase letter: !"。
  - doctype 关键字**大小写不敏感**(对齐 templ 的 `parse.StringInsensitive("<!doctype ")`),但**必须带那个分隔空格** —— `<!doctypehtml>` 不是 doctype,仍按元素名报错(有测试钉住这条边界)。
  - 注释的切法与 templ 逐字对齐:先读到第一个 `--`,再要求紧跟 `>`。所以 `<!--a--b-->` 和 `<!--a--` 都报 `comment contains invalid sequence '--'`,没闭合报 `expected end comment literal '-->' not found`。
  - **`HTMLComment` 内容不含分隔符**定案(与 templ 的 `Contents` 一致):生成器写回时补 `<!--`/`-->`,由 `generator_test.mbt` 的"a parsed comment keeps its delimiters"钉住。
  - **偏差:`DocType` 从无载荷变体改成 `DocType(String)`**,携带关键字与 `>` 之间的那段值。templ 的 `DocType` 同样有 `Value` 字段。若保持无载荷,生成器只能硬写 `<!doctype html>`,`<!doctype svg>` / `<!doctype html PUBLIC ...>` 就会被**静默改写成 HTML5 的 doctype** —— 那是产出了错的内容,不是少了个功能。关键字仍然统一成小写(`<!DOCTYPE HTML>` → `<!doctype HTML>`,与 templ 的 `writeDocType` 一致),值原样保留。改动波及 `parser/pkg.generated.mbti` 与 3 处测试字面量。
  - 端到端实测:写一个带 `<!DOCTYPE html>` 与 `<!-- the greeting -->` 的真实页面走一遍 CLI,产物 HTML 逐字节正确(临时文件已移走)。
  - 遗留:这次顺带发现产物**不是** `moon fmt` 的不动点(超 80 列的 `write_string` 会被折行),已拆成 T2.19。
- [x] **T2.19** 把生成产物排除出 `moon fmt`,并更正 T2.16 记错的那条结论 — `moon fmt` **折行阈值实测为 80 列**(80 列不动、81 列折行,缩进 2 与 6 都一致),所以只要字面量或抄进来的表达式够长,产物就会被重排;T2.16 写的"产物是 `moon fmt` 的不动点"是**错的**,而抄进产物的表达式长度由用户决定,靠构造不可能补全这个保证。正解是在用户包的 `moon.pkg` 里逐个文件写 `formatter(ignore: ["hello_templ.mbt"])`(**已实测有效**;本条原写的是 `"*_templ.mbt"` 这种 glob 写法,**实测无效**,已改)。需要:更正 port-research §6.1、更正 TASKS.md 里 T2.15/T2.16 的相应措辞、把这条写进 `examples/hello/moon.pkg` 与 README · 前置 T2.17 · S
  - 触发与阈值都是测出来的,不是推的:构造一组只差字面量长度的 `w.write_string("aaa…")`,在**缩进 2 空格**下 80 列不动、81 列折行;在**缩进 6 空格**下分界同样是 80/81 —— 说明判据只看到底有几列,与缩进层级无关。真实场景复现:一个带 `<!DOCTYPE html>` 与正文的页面走完 CLI,产物的 `w.write_string(...)` 被折成三行。
  - **为什么不去补这个保证**:折行的另一半触发源是**抄进产物的用户表达式**(`{ some_long_call(a, b, c) }` 原样进产物),它的长度生成器管不着。要么内联 formatter(T2.16 已否决,版式对不上),要么就是排除。所以补字面量切分只能修一半,不值得引入一个写死 80 这种魔数的逻辑。
  - **`formatter(ignore:)` 的两个实测结论**:有效 —— 列进去的文件原样不动;**不支持 glob** —— 写 `"*_templ.mbt"` 那个文件照样被格式化。所以每个生成文件都得单列一行(与 §3.3 里 `pre-build` 的 `input` 是同一个痛点)。
  - 落点:`examples/hello/moon.pkg` 加上 `formatter(ignore: ["hello_templ.mbt"])`,这是用户会照抄的样板;port-research §6.1 整段改写,§3.3 与风险表同步纠正;TASKS.md 里 T2.15/T2.16 两条断言"不动点"的措辞一并改掉。
  - README 部分**留给 T5.5**:当前 `README.md` / `README.mbt.md` 只有一行标题,写文档是 T5.5 的整块工作,不在这里顺手起个头。
- [x] **T2.18** 大写模板名生成非法 MoonBit — 生成期明确报错,templ 侧允许 `templ Hello()` 而 MoonBit 的 `fn` 名必须小写写起。**实测证据**:`templ Hello()` 产出 `pub fn Hello() -> Unit` → `Parse error, unexpected token `(`, you may expect `::``;带接收者的 `templ (m : Model) Render()` 产出 `pub fn Model::Render(...)` → `Expected lower case identifier for name of `fn``。报错要指出是模板名的大小写问题并给出模板名与位置,不要让它变成用户看不懂的产物编译错误 · 前置 T2.15 · S
  - 新增 `Generator::check_name`,在 `write_template` 一开头、**写任何东西之前**调用(所以报错里的名字就是源码里的那个,不会指向半成品产物)。判据是**首字符必须是 `a`–`z` 或 `_`**,与实测一致:`pub fn _leading()` / `pub fn foo_bar()` / `pub fn fooBar2()` 都合法,`pub fn Hello()` 与 `pub fn 9lives()` 都是 parse error(MoonBit 解析器把首字母大写当类型名)。名字**中间**的大写不管。
  - 报错文案:`a template name must start with a lowercase letter or `_`, because it becomes a MoonBit function name, but this one is `Hello` (in template `Hello`)`。带接收者的模板走同一条规则(方法名同样不能大写)。
  - **顺带修掉三个既有测试:它们在断言 `Greeting` 的产物**,而现在 `check_name` 把它们挡下来了 —— 也就是说这些期望值本来就是在断言一段**编译不过的 MoonBit**。改成 `greeting` 后通过。这是 T2.18 之外的一个真实修正:`Generator` 的接收者路径此前**只被断言过产物文本,从未真正编译过**。
  - 补做端到端验证(临时包,已移走):`templ (self : Model) greeting() { <div>Hello, { self.name }!</div> }` → `pub fn Model::greeting(self : Model) -> @rt.Component`,配 `@rt` 与 `struct Model` 后 **`moon build` 零警告通过**,运行打出 `<div>Hello, world!</div>`。接收者路径至此才算真的验证过。
  - 观察到但**不在本次范围**:接收者**类型**名若小写(如 `(m : model)`)产物同样编译不过,但那种情况下用户自己的 `struct model {}` 本来就已经非法,报错点也落在用户自己的代码上,不急着在这里拦。

---

## Phase 3 — MVP 完整(达成 M2)

- [x] **T3.1** 表达式属性 `name={ expr }` — 生成 `resolve_attribute_value` 调用;快照测试 · 前置 T2.4、T2.15 · M
- [x] **T3.2** 组件调用 `@expr` / `@expr { }` — 生成 `.with_children(...).render(...)`;校验 `@` 前必须有空白 · 前置 T3.1 · M
- [x] **T3.3** `{ children... }` + children 前导的三级发射规则 — 按 port-research §3.2 的表分级发射(避免 `unused_value`);单测验证 children **不透传**到孙子组件 · 前置 T3.2 · M
- [x] **T3.4** `if` / `else if` / `else` — 条件原文抄进产物交给 MoonBit 编译器校验;校验 `{` 后必须换行 · 前置 T2.15 · M
- [x] **T3.5** `for`:C 风格与 `for..in` 两种形式 — 两种形式各有快照;注意 MoonBit C 风格 for 写 `i = i + 1` · 前置 T3.4 · M
- [x] **T3.6** 控制流分支:`match`(T0.1 已定,不用 Go 风格 `switch`)— 快照测试;需支持解构模式 `Some(x) => { ... }` · 前置 T3.5 · M
- [x] **T3.7** `{ attrs... }` spread — 生成 `@rt.render_attributes` 调用 · 前置 T3.1 · M
- [x] **T3.8** `{{ code }}` 原样写入函数体 — 单测:`{{ let x = 1 }}` 在产物中按 `let` 出现 · 前置 T2.15 · S
- [x] **T3.9** 目录扫描 + 批量生成(`generate ./...`)— 一条命令生成整目录;跳过无变化文件(等价 templ `-lazy`)· 前置 T2.14 · M
  - 参数形态:`generate <file.templ>`(老行为)/ `generate <dir>/...` / `generate <dir>`(裸目录等价于 `<dir>/...`)。`...` 单独出现即当前目录。判据是**参数形态**而不是"路径恰好是目录":写了 `./...` 却不存在时,报的是 `cannot read <dir>`(目录语境),不会退化成"读文件失败"这种看不出问题的提示。
  - **无变化即不落盘**:目标已存在、且内容与本次生成**逐字节相同**时返回 `Unchanged`,不写文件 —— 避免 mtime 变化让下游构建白跑一遍,正是 templ `-lazy` 的目的。**偏差**:templ 比的是 mtime(`goFileIsUpToDate`:`goFile mtime.After(templ mtime)`),我们比的是内容。理由:mtime 会被 `touch`、`git clone`、跨机器时钟差骗到,内容才是真正决定"构建有没有活干"的东西;代价是省不掉解析与生成的开销(实测 mtime 在跳过时确实不变)。
  - `generate_file` 返回值由 `String` 改为 `enum Generated { Written(path~) | Unchanged(path~) }` —— 单文件路径也要能分辨这次到底写没写。
  - **批处理不因单个文件出错而中止**:每个失败打到 stderr 并继续走完剩下的文件,最后整体退 1。理由:一整棵树里坏一个模板就看不到其余诊断,是批处理最烦人的地方;`moon build` 也是这么做的。
  - **空目录报错退 1**(`no .templ files under <dir>`),不静默成功 —— 路径打错时静默成功是最坏的结果。目录不存在则更早地报 `cannot read <dir>`。
  - **踩到的坑:`Array[String]::sort` 不是字典序!** MoonBit 的 `impl Compare for String` **先比长度再比内容**(`builtin/string.mbt:333`),所以 `["a_templ.mbt", "a.templ", "nested"].sort()` 得到 `nested, a.templ, a_templ.mbt`。实测确认后改用 `sort_by(fn(a, b) { a[:].lexical_compare(b[:]) })`,遍历顺序才和 `ls` 一致且跨机器稳定。**这条对任何"给字符串数组排序"的地方都成立**,值得记住。
  - 单测只覆盖不写盘的部分(`is_tree_argument` / `tree_root` / `templ_files_under` 走真实目录 / `run` 的拒绝分支),沿用 T2.14 的判据:往仓库里写临时文件会留垃圾。写盘与跳过路径**手工实测**(临时树放在 `_scratch/`,移走后无残留):新文件 `generated`、第二次 `is up to date` 且 mtime 不变;批处理里坏模板报错而其余文件照常生成、退 1;手写同名文件被防覆盖挡下且未被改动;`generate ./...` 在仓库根跑完整棵树,`examples/hello/hello_templ.mbt` 报 `is up to date` 且 mtime 不变。
- [x] **T3.10** **端到端 M2**:写一个真实页面 — 布局组件 + 循环 + 条件 + children + 跨包组件调用,输出正确 · 前置 T3.3、T3.5、T3.6 · M
  - 落点是 `examples/site`(**两个包**,这是第一次真的跨包):`examples/site/layout.templ`(带 `{ children... }` 的整页骨架)、`examples/site/page.templ`(页面:调 `@layout(...)` 并把列表作为 children 交给它,里面 `for post in posts`,每个 post 走 `if post.published`,真分支调 `@@ui.card(...)`)、`examples/site/ui/card.templ`(可复用的卡片组件),外加 `models.mbt`(`Post` 结构)与 `main.mbt`(`moon run examples/site` 直接打出整页 HTML)。一个页面同时覆盖布局 + 循环 + 条件 + children + 跨包调用五件事。
  - **跨包调用要动 `moon.pkg`**:`examples/site/moon.pkg` 里 import `daqing/moon-templ/examples/site/ui`(产物写的是 `@ui.card(...)`)。写文件时显式写了 `@ui` 别名,`moon fmt` 把它删了 —— 末段名就是默认别名,删掉照样编过,说明这条路不依赖别名而依赖包名。
  - **逐字节对 templ 校验**:三个模板体分别喂给 Go 探针的 `literals` 模式(`_scratch/probe/sitecases.txt`),布局与卡片两支的**字面量序列与我们的产物完全一致**;页面那支探针只吃 Go 的循环头(`for _, item := range items`),把头部换成 Go 拼法后字面量同样是 `<ul class="posts">` `<li class="post">` `<span class="draft">` `§` `</span>` `</li>` `</ul>` —— 换行全部被块吞掉,标签之间没有空白。顺带钉死两件事:(a) `<!DOCTYPE html>` → `<!doctype html>` 的大小写变化是 **templ 自己的行为**,不是我们的偏差;(b) `@call { ... }` 的 children 块在 templ 里也是一个内嵌组件、且**继承外层已 clear 的 ctx**,与 `with_children(@rt.component(...))` 一致。
  - 断言(`examples/site/site_wbtest.mbt`,3 个):整页 HTML 逐字节相等;空 posts 时布局照旧包住空 `<ul class="posts"></ul>`;数据里的文本**被转义**(`Q&A` / `Tea & crumpets <3` / `5 > 4` —— 页面自己写的那处与**另一个包里卡片写的那处**都转义)。
  - **防漂移守卫扩到全树**:`cli/example_wbtest.mbt` 原来只盯 `examples/hello`,现在遍历 `example_templates()` 里的四个模板逐个比对产物;另加一条"树里走到的模板集合 == 清单"的测试,新加一个 example 忘了登记会在这里红,而不是"签入了却从没被校验过"。`cli_test.mbt` 里 walk 的期望值同步成四个(顺带真的覆盖了子目录 `examples/site/ui`)。
  - 实测证据:`moon check` 零警告;`moon test` **316 passed / 0 failed**(较 T3.9 的 312 多出 3 个 example 测试 + 1 个守卫测试);`moon run examples/site` 打出的整页与断言逐字节相同;再跑一次 `generate examples/site/...` 三份产物都报 `is up to date` 且 mtime 不变(产物是 `moon fmt` 的不动点,`formatter(ignore:)` 覆盖了新包的两个产物)。
  - **仍然存在的运行时缺口(非本次引入)**:T3.7 生成的 `@rt.render_attributes` 要等 **T4.1** 才有实现,所以这个页面**故意不用** `{ attrs... }`;`{ attrs... }` 现在能解析、能生成,但产物要等 T4.1 才编得过(此前 spread 是解析错误,所以没有回归)。
  - **M2 达成**:`moon-templ` 现在能写这样一个真实页面并输出正确 HTML。
- [x] **T3.11** 移植 templ 条件/循环/调用 golden — `test-if` / `test-for` / `test-call` 目录转为 MoonBit 快照测试 · 前置 T3.6 · M
  - 落点 `golden/if`、`golden/for`、`golden/call`,**一个 templ 目录一个包**:templ 那三个目录各自是独立的 Go package,而 MoonBit 没有重载 —— `test-if` 与 `test-for` 的模板都叫 `render`,挤在一个包里根本编不过,分包是唯一能保留原名的写法。每个包 = `<名>.templ` + 产物 + `moon.pkg` + `_wbtest.mbt` 断言。
  - **断言值逐个对着 `expected.html` 核过**:三个 golden 文件去掉换行后**与断言逐字节相同**(`tr -d '\n'` 实测:`True` / `<div>a</div><div>b</div><div>c</div>` / `<div>A</div><div>B</div><div>C</div><div>Legacy call style</div><div>e</div><div id="wrapper"><div>Child content</div></div>`)。**`expected.html` 里的换行是 templ 的 htmldiff 给块级元素排版用的,不是产物**,所以断言里标签之间没有空白 —— 这点用 Go 探针独立验过:`if` 体产出的字面量是 `§§`(分支前后无空白),`for` 体是 `<div>§</div>`(**一整段**,说明相邻两次迭代之间无空白),`showAll` 体只剩 `<div>Child content</div>`(调用本身不写字面量)。
  - **移植时的三处必然改写**(都是语言差异,不是行为差异):`data` → `Data`(MoonBit 类型名必须大写);`showAll` / `showOne` / `wrapChildren` → `show_all` / `show_one` / `wrap_children`(**T2.18** 的规则:模板名会变成 `fn` 名,不能大写开头);`for _, item := range items` → `for item in items`(T3.5 的两种形式之一)。模板体本身一字未改:`{ "True" }` / `{ "False" }` / `@child` / `@component` / `{ children... }` / `@b(c("C"))` / `@show_one(e())` 都是原样可用。
  - `test-if` 的 golden **只覆盖了 `if` 的一半** —— `data.IsTrue()` 写死返回 `true`,`else` 分支从没被渲染过。移植时把 `Data` 存成 `value : Bool`(配 `Data::new`),两个分支各断言一次,补上 templ 没测的那一半。
  - **防漂移守卫扩到 golden**:`cli/example_wbtest.mbt` 改名 `cli/checked_in_wbtest.mbt`(`git mv`),清单从"examples 四个"扩成 "examples + golden 共七个",walk 的根也从 `examples` 变成 `["examples","golden"]`(仓库根**故意不 walk**:底下有 `_build` 与依赖目录,那里出现的 `.templ` 不是我们的)。
  - 踩到的坑:`Data` 只在**测试文件**里构造,`moon check`(不带测试编译)于是报 `struct_never_constructed` —— 结构体在被测代码里没有构造点。加 `Data::new` 后消失。**这条对任何"只在测试里 new 的类型"都成立**。
  - 实测证据:`moon check` 零警告;`moon test` **319 passed / 0 failed**(较 T3.10 的 316 多出 3 个 golden 测试);三个 golden 包的产物在 `generate golden/...` 下报 `is up to date`。

---

## Phase 4 — 属性特殊语义(达成 M3)

> templ 对四类属性有超出"输出键值对"的特殊处理(port-research §1.2)。这一阶段把语义补齐。

- [x] **T4.1** runtime:`Attributes` / `RenderAttributes` — 单测:map 与 KV 数组两种输入 · 前置 T1.1 · M
  - **【T4.4 更正】本条原先写的"MoonBit 不允许给不属于本包的类型实现 trait"是错的。** 当时临时建两个包(A 定义 `pub(open) trait T`,并 `impl T for Map[String, Int]` / `impl T for Array[String]`,**没带 `pub`**;B 调 `@a.use_it(m)`)只看到 `Unused trait implementation` / `no ``impl`` is defined`,于是归因到"类型归属"上,但真正起作用的是 `pub`:T4.4 里 `runtime` 就有 `pub impl Stylable for String`(`String` 是内建类型,不是本包类型),`.mbti` 里照样看得到;同一形状的探针(A 里 `pub impl T for Map[String, String]` / `pub impl T for Array[String]`,B 用 `@a.render(...)` 走 `[A : T]` 泛型调用)也编译通过、断言通过。**结论:`Map` / `Array` / `String` 这些都能实现本包的 trait,绊住当时的只是漏写 `pub`。**
  - 形状据此改:两种输入合成**一个** `Attributes` 结构(内部 `priv items : Array[KV[String, AttributeValue]]`),由两个构造器给出 —— `from_map`(按名排序,对齐 templ 的 map)与 `ordered`(保持给定顺序,对齐 templ 的 OrderedAttributes)。`Attributer` trait 仍然保留,但只对我们自己的类型实现;`pub(open)` 让调用方还能给自己的类型实现它,自定义属性来源的路没堵死。
  - **`pub impl` 与 `impl` 的差别是实测出来的**:`impl Attributer for Attributes`(不带 `pub`)一样被报 `Unused trait implementation`,下游也看不见;加上 `pub` 才对下游可用。这条对任何"要给下游用的 trait impl"都成立 —— 也解释了上一条的误判。**把两种输入合成一个 `Attributes` 结构的形状仍然保留**(templ 的 `Attributes` 与 `OrderedAttributes` 是两个来源,合成一个结构配两个构造器更简单),但它不是语言逼出来的,`pub(open)` 的 trait 照样允许调用方给自己的类型实现。
  - **`typealias` 是 `.mbti` 的关键字,源码里要写 `pub type`**:写 `pub typealias` 直接 parse error(`unexpected token id`)。
  - **泛型函数的类型参数写在名字前面**:`pub fn[A : Attributer] render_attributes(...)`;写成 `fn f[T](...)` 报 `unexpected ``fn f[T]``, you may expect ``fn[T] f```。
  - 动态类型没有了:`map[string]any` 上的 switch 换成 `AttributeValue` 的三个变体 `Value(String)` / `Flag(Bool)` / `Conditional(KV[String, Bool])`。templ 的 `*string`、`*bool`、`func() bool` 三种情形在这里落在 `Value` / `Flag` 上(空指针等于"不出现",`func() bool` 由调用方求值),理由是没有 `any` 就没有运行期分派。
  - 排序沿用 T3.9 的结论:map 的项用 **`lexical_compare`** 排,不能用 MoonBit 的 `Compare for String`(先比长度),否则 `zz` 会排在 `aaa` 前面;有单测钉住这条。templ 是在**渲染时**排序(`Items()`),我们是在**构造时**排 —— `items` 私有、构造后改不了,两者等价。
  - 单测 8 条:map 顺序无关、ordered 保序、`false` 标志整条消失、条件属性、名字与值转义、空集、按名而非按长度排序。
  - 端到端实测:`<div class="box" { attrs... }>hi</div>` 走 CLI 生成 → `moon build`/`moon run` 打出 `<div class="box" hidden id="x&amp;y">hi</div>`(临时包已移走)。顺带把 T3.10 记的那个缺口补上:该条目里"页面故意不用 `{ attrs... }`"的原因(运行时没有实现)至此消失。
  - `moon check` 零警告(补了 `pub extend Attributes with Attributer::{items}` 消掉 `implicit_impl_as_method`);`moon test` **327 passed / 0 failed**(较 T3.11 的 319 多出 8 个 runtime 单测)。
- [x] **T4.2** runtime:`CSSClasses` / `KV` — 单测:常量与表达式混合、空值剔除 · 前置 T4.1 · M
  - `KV` / `kv` 已在 **T4.1** 落地(散列属性列表本身就要一对名值),这里只补 `CSSClasses`:一个 `priv items : Array[CSSClass]`,配 `CSSClass::new` 式的构造 `CSSClasses::new`,以及 `impl Show`(对齐 templ 的 `String()`,名字不转义 —— 转义属于它落进去的那个属性值,T4.3 那一步做)。
  - `CSSClass` 是 `Name(String)` / `Toggle(KV[String, Bool])` 两个变体,与 `AttributeValue::Conditional(KV[String, Bool])` 同构。templ 在 `Classes(...)` 里收 `any`(字符串、`templ.KV`、`map[string]bool`、`[]string`、`ComponentCSSClass` 等)再按动态类型分派;没有 `any` 就没有运行期分派,能表达的写法直接就是这两个变体,map 形态由调用方自己展开。`ComponentCSSClass` 属于 T6.1,`unknownTypeClassName` 那条兜底(给不认识的类型渲染 `--templ-css-class-unknown-type`)在这里不可能触发,不实现。
  - **`cssProcessor` 的两条规则逐字对齐**(读的是 templ 的 `runtime.go` 与它自己的 `TestClassesFunction`):**顺序取名字第一次出现的位次,开关取最后一次写下的值**。所以 `["a", KV("a", false)]` 一个都不输出,而 `[KV("a", false), "a"]` 输出 `a`;重复的名字只输出一次。templ 的用例 `["a", KV("b", true), "c", KV("c", false), KV("d", true), KV("e", false)]` → `"a b d"` 原样搬成一条单测。
  - **不排序**:这里与 T4.1 的 map 相反,templ 是按写入顺序输出的,单测 `["zz", "aaa"]` → `"zz aaa"` 钉住这条(避免顺手套用 T4.1 的排序)。
  - 单测 7 条:常量与开关混合、后写的开关关掉前面的名字、后写的名字把开关重新打开、重复名字只出一次、保序、空表与全关、名字不转义(对齐 templ 的 `"a </style>"` → `"a </style>"`)。
  - `moon check` 零警告;`moon test` **334 passed / 0 failed**(较 T4.1 的 327 多出 7 个)。
- [x] **T4.3** `class` 属性特殊处理 — 表达式走 `CSSClasses`,常量值 join 消空白;对 templ golden 校验 · 前置 T4.2、T3.1 · M
  - templ 的规则就读它那三行(`generator/generator.go:1234`):`if k, ok := attr.Key.(parser.ConstantAttributeKey); ok && strings.EqualFold(k.Name, "class") { attrValue = strings.Join(strings.Fields(attrValue), " ") }`。**只对常量属性**、名字用 `EqualFold` 比对。照搬成 `is_class_attribute`(`name.to_lower() == "class"`)与 `collapse_class_whitespace`(等价 `strings.Join(strings.Fields(v), " ")`),加在 `Generator::write_attribute` 的 `Constant` 分支上。
  - `strings.Fields` 按 Go 的 `unicode.IsSpace` 切,不只是空格/Tab/换行:单测里 `a\u{00a0}b\u{0085}c`(不换行空格 + NEL)→ `a b c`,把这条钉住。
  - **名字的大小写原样输出**:`<div CLASS="a  b  c">` 生成 `<div CLASS="a b c">`。templ 自己生成的 Go 也是 `CLASS`(见 `test-class-whitespace/template_templ.go` 第 6 行),那边 `expected.html` 写 `class` 是 htmldiff 解析 HTML 时把属性名规范化了,不是 templ 的输出。wbtest 的注释里说明这点,免得后人以为我们多了个大小写偏差。
  - **表达式一侧生成器一行都不用改**:templ 之所以包一层 `templ.CSSClasses(expr).String()`,是因为它要在 `any` 上做运行期分派;这里没有 `any`,调用方直接写 `@rt.CSSClasses::new([...])`,表达式属性照原路走 `@rt.resolve_attribute_value(...)` —— T4.2 的 `Show for CSSClasses` 给出列表、外层照常转义。所以"表达式走 CSSClasses"在生成器里是**零改动**,能成立是因为 T4.2 的 `impl Show` 就是那个 `String()`。
  - 顺带钉住一条容易误解的边界:`class={ "a  b" }`(裸字符串表达式)**不消空白** —— templ 里字符串整体算**一个**类名(`cp.AddClassName(c, true)`,不切),空格是它自己的。所以"消空白"是**常量值**的规则,不是"名字叫 class"的规则;有单测。
  - golden:`golden/class/` 移植 templ 的 `generator/test-class-whitespace`(6 个模板 + `test_component`),模板名按 T2.18 转 snake_case。逐条对过:`templ@v0.3.1070/generator/test-class-whitespace/template_templ.go` 里那 6 行 `WriteString` 与我们的 `class_templ.mbt` 逐字相同。另加两个 gold 里没有的模板(`expression_class_list` / `expression_string_is_one_name`)补表达式那一侧 —— 原 golden 只有常量,不然这半条任务没有端到端覆盖。已在 `cli/checked_in_wbtest.mbt` 的 `checked_in_templates()` 登记(否则"树里每个模板都被检查过"那条会红)。
  - `moon check` 零警告;`moon test` **340 passed / 0 failed**(较 T4.2 的 334 多出 6:生成器 3 + golden 3)。
- [x] **T4.4** `style` 属性 sanitize — 对 templ golden 校验 · 前置 T4.1 · M
  - 生成器只改**一行**:表达式属性那个调用名改由 `attribute_value_call(name)` 给 —— `style` 走 `@rt.sanitize_style_attribute_value`,其余走 `@rt.resolve_attribute_value`。templ 就是按属性名**精确匹配**选的(`generator.go` 里 `name == "style"` 才包 `SanitizeStyleAttributeValues`),不折叠大小写,所以 `STYLE={ s }` 仍然走普通转义;有单测钉住两个名字各走哪条。
  - **常量属性与散列属性故意不 sanitize**:templ 的 `writeConstantAttribute` 只特判 `class`,`RenderAttributes` 里没有任何按名分派,两边都是原样输出。
  - `style={ ... }` 的取值面按 templ 的 `SanitizeStyleAttributeValues(values ...any)` 铺开。它那个 `switch value.(type)` 认得字符串、`templ.SafeCSS`、`map[string]string`、`map[string]templ.SafeCSSProperty`、`[]KeyValue[string,string]`、`[]KeyValue[string,bool]`、`[]KeyValue[SafeCSS,bool]`,再加反射那条(切片、`func() string` 之类)。没有 `any` 就没有运行期分派,于是把"值是什么"写进类型:`StylePart` 的六个变体(`Text` / `Trusted` / `Property` / `TrustedProperty` / `Toggle` / `TrustedToggle`),配一个 `Stylable` trait,`String` / `SafeCSS` / `Style` 各实现一次。map 的两个形态由 `Style::from_map` / `Style::from_trusted_map` 给(map 无名序,照 T3.9 用 `lexical_compare` 排),变体数组走 `Style::new`。
  - sanitize 逐条照搬 templ 的 `sanitize.go`:整串走 `processString`(按 CSS 字符串 token 转义,去首尾空白,补分号),按 `;` 切声明、再按第一个 `:` 分名值。值按属性名有三条专门规则 —— 枚举类属性(如 `display`)走 `sanitizeEnum`,属性名带 `font-family` 的走 `sanitizeFontFamily`,带 `background-image` 的走 `sanitizeBackgroundImage`;其余走 `sanitizeRegular`。属性名统一小写(`COLOR` → `color`,单测钉住)。
  - `sanitizeRegular` 那张字符类是 `[0-9a-zA-Z+-.!#%_ \t]`,**`+-.` 是范围不是三个字符,所以逗号在集合里** —— templ 源码里那条"逗号会挡掉值"的注释与它自己的正则不符,以正则为准,单测把逗号放行钉住。`*` / `/` 只在不构成注释时放行(`a*`、`*a`、`*` 通过,`**`、`a//b`、`a/*b*/c` 挡掉)。
  - 挡掉之后不是丢弃而是换成无害值,整条声明也留在输出里好让人看见:值为 `zTemplUnsafeCSSPropertyValue`(`sanitizeCSSValue`),属性名不是合法名字时名与值一起换成 `zTemplUnsafeCSSPropertyName:zTemplUnsafeCSSPropertyValue`(`sanitizeCSSProperty`)。
  - `urlIsSafe` 是把 Go `url.Parse` 的错误面照搬过来的:`%` 后面不是两个十六进制、控制字符、开头就是 `:`,以及无 scheme 且非根路径时首段里有 `:`(如 `a:b.png`)—— 都算"跟不得"。`background-image` 里出现 `<` / `>` 直接挡掉。
  - **转义两次是 templ 的行为,不是这里的笔误**:每一片先按 CSS 字符串 token 转义(`</style>` → `\00003C/style`,空字符换成替换字符而不是转义),整个结果再被属性转义一次,所以 `a&b` 出来是 `a&amp;amp;b;`;单测 "the attribute escapes what the sanitizer escaped" 钉住这条。落法:运行时 `sanitize_style_attribute_value(v) = escape(v.sanitized())`,生成器直接 `w.write_string(...)`。
  - **差分校验**:把 158 个输入(整串、裸串、KV 六种、map 两种、`url(...)` 的各种引号与编码、危险值、边界)同时喂给真 templ(Go,`GOPROXY=off` 走本地模块缓存)与本实现,逐条比对 **158/158 一致**。唯一一次不符是 `url("https://example.com/a.png`(引号不配对),它把我们漏掉的两条检查逼了出来(`%` 转义、首段冒号)。临时语料测试跑完即移走,换成 19 条带注释的单测。
  - golden:`golden/style/` 移植 `generator/test-style-attribute`。那份 golden 只有**一个泛型模板** `Button[T any]`,被调用七次、每次一种值;本项目的解析器不支持泛型模板(`split_signature` 在模板名后要 `(`,`[` 直接报错),于是拆成三个模板(分别收 `String` / `@rt.Style` / `@rt.SafeCSS`),七种输入各断言一次。golden 的 `expected.html` 是给人看的写法(冒号后带空格、无分号)且走 HTML diff;真实产物已用 Go 探针逐字核对:两个按钮是 `background-color:blue;color:red;` 与 `background-color: red;`(函数返回那条留着空格、再补分号),按这个写进断言。已在 `cli/checked_in_wbtest.mbt` 登记。
  - `moon check` 零警告;`moon test` **362 passed / 0 failed**(较 T4.3 的 340 多出 22:运行时 19 + 生成器 2 + golden 1)。
- [x] **T4.5** URL 白名单:`a[href]` `link[href]` `form[action]` `object[data]` — **故意用 `javascript:` 输入,断言被拦截** · 前置 T4.1 · M
  - 规则是 templ 的 `isExpressionAttributeValueURL(elementName, attrName)`(`generator.go:1852`),**元素名与属性名成对判断**:`a` / `link` 的 `href`、`form` 的 `action`、`object` 的 `data`,别处没有 —— 注意 **`src` 不在名单里**(`<img src={ u }/>` 走普通转义,已用真 templ 生成核对过)。生成器据此新增 `is_url_attribute(element, name)`,并把**元素名**一路传进 `write_attribute` / `write_expression_attribute`(此前只传属性名)。
  - 两个名字都是**精确匹配**,templ 也是:属性名不折叠,所以 `<a HREF={ u }>` 走普通转义。这是 templ 的行为(它连大写元素名都解析不了 —— 实测 `<A>x</A>` 直接报 `close tag not found`,本项目解析器同样要求元素名以小写字母开头)。**这是 templ 的一个已知缺口**:浏览器把 `HREF` 读作 `href`,而它不过白名单;这里照搬不擅自加宽,仅在此记录。
  - 白名单本身是 `templ.URL`(`url.go:12`):取第一个 `:` 之前的文本当 scheme,**只有当它里面没有 `/` 时**才算 scheme,然后 scheme 必须是 `http` / `https` / `mailto` / `tel` / `ftp` / `ftps` 之一(不分大小写),否则换成 `FailedSanitizationURL` = `about:invalid#TemplFailedSanitizationURL`。照搬为 `url()` + `is_safe_scheme()`。边界值得记两条:`?a=b:c` 与 `#a:b` 被读成 scheme `?a=b` / `#a:b` 而**挡掉**,`//javascript:alert(1)` 因为 `//javascript` 里有 `/` 而**放行**(与 templ 一致)。
  - `JoinURLErrs[T ~string]` 里那次运行期类型断言(`any(s).(SafeURL)`)是这套东西的关键:值本来就是 `SafeURL` 就不再过滤。没有 `any`,改用 trait `AsURL`(`as_url(Self) -> SafeURL`),`String` 与 `SafeURL` 各实现一次 —— 与 T4.4 的 `Stylable` 同一个路子,而且调用方可以给自己的类型实现。代价是**静态分派**而非运行期判断,对这两个类型而言结果一致。
  - **不需要错误通道**:`JoinURLErrs(expr)` 只 join 了一个空列表(`errors.Join()` 无参返回 nil),templ 生成的那段 error handler 是死代码 —— 白名单挡下来的 URL 照常渲染,只是变成 `about:invalid#…`。所以 `sanitize_url` 直接返回 `String`,生成器不加返回值。
  - `SafeURL` 配了 `Show`(写出原样的 URL,对齐 templ 里 `SafeURL` 就是 string 类型、`string(u)` 可取),这样它在**非** URL 属性上(`title={ safe_url }`)也走 `resolve_attribute_value`,转义一次 —— 与 templ 的 `ResolveAttributeValue` 默认分支 `EscapeString(fmt.Sprint(v))` 一致。
  - **差分校验**:41 个输入(六种 scheme 的大小写、`javascript:` / `data:` / `vbscript:` / `about:` / `file:` / `blob:` / `chrome:`、`a:b` / `:x` / `?a=b:c` / `#a:b` / `/a:b` / `a/b:c` / `//javascript:…`、带端口与查询串等)同时喂给真 templ 的 `templ.URL` 与本实现,逐条比对 **41/41 一致**。
  - golden:`golden/url/` 移植 `generator/test-a-href` 与 `generator/test-form-action`(前者 3 个 `<a>`,后者 5 个 `<form>`,含两个"函数返回值"形态)。两个 Go 版的辅助函数返回 `(T, error)`,这里没有错误,于是 `safe_url` / `string_url` 只在返回类型上有别。另加两个 golden 没覆盖的:`link[href]` + `object[data]`,以及反例 `img[src]` + `a[title]`。
  - golden 的断言是**逐字对齐真 templ 渲染结果**的:`a-href` 与 `form-action` 两段输出(含元素之间的空格 —— `<a>` 是 inline 所以留空格、`<form>` 是 block 所以不留)与真 templ 渲染逐字节相同;`link/object` 与 `img/title` 那两个模板在临时模块里用 `templ generate` 生成后渲染,同样逐字节相同。golden 的 `expected.html` 是给人看的写法,它对的是 HTML diff,不是字节。
  - `moon check` 零警告;`moon test` **368 passed / 0 failed**(较 T4.4 的 362 多出 6:运行时 3 + 生成器 2 + golden 1)。
- [x] **T4.6** 事件属性 `on*` / `hx-on:*` → `ComponentScript` — 输出 `.Call` 而非转义值 · 前置 T4.1 · M
  - 规则是 templ 的 `isScriptAttribute(name)`(`generator.go:1130`):**前缀匹配**,`on` 与 `hx-on:` 两个前缀各判一次。前缀匹配比"事件属性"宽:实测 `once`、`on-click` 都算,照搬。名字**不折叠**,所以 `OnClick` 不算 —— 见下面那条 templ 的 bug。
  - 落法是 `attribute_value_expression(element, name, expr)` 一个函数把 templ `writeExpressionAttribute` 的**四路顺序(URL → script → style → 默认)照原样**写在一处,替换 T4.4 的 `attribute_value_call`。前三路里只有 script 一路的**形状**不同:表达式要以 `ComponentScript` 作答,写进去的是它的 `call`;其余三路仍是 `@rt.xxx(expr)` 包一层。templ 那里先 `var vn templ.ComponentScript = <expr>` 再 `Buffer.WriteString(vn.Call)`,那句声明就是它的类型检查;这里 `.call` 字段访问起同样作用,给错类型编译期就报错。
  - **`.Call` 不再转义一次**是这条规则的实质:templ 的 `SafeScript(name, params...)` 在构造 call 时就把每个参数 JSON 编码、再对整条 call 做一次属性转义,所以字符串参数的引号到达属性时已经是 `&#34;`;写出时**原样**写。再转义一次会变成 `&amp;#34;`,浏览器就会把 `&#34;` 当字面文本 —— golden 里 `withParameters` 那条断言正是钉这个(与真 templ 逐字节一致)。
  - 常量属性不走这条路:templ 只读表达式产生的值,常量 `onclick="alert(1)"` 照原样写。templ 的 `test-script-usage` 里 Button C / Button D 两个常量按钮就是这个样子,已抄进 golden。
  - 新增运行时类型 `ComponentScript { call : String }`(templ 的 `Name` / `Function` / `CallInline` 与 `RenderScriptItems` 属于 T6.2,这里刻意不做)。它**特意没有实现 `Show`**:templ 的 `ResolveAttributeValue` 里有一条 `case ComponentScript: return v.Call`(runtime.go:702,**不转义**),所以它的 `OnClick={ handler }` 一样能渲染出 call;本项目 `resolve_attribute_value[T : Show]` 走的是 `escape(show(v))`,给 `ComponentScript` 实现 `Show` 就会**多转义一次**,渲染结果与 templ 相反。宁可让这种模板**编译不过**(属性名没说这个值是脚本,就不该往里放脚本),也不静默渲染出坏掉的 JS —— 这是刻意与 templ 分道的一处,已记在 golden 的测试注释里。
  - **顺带查实 templ 的一个 bug**:`getAttributeScripts`(`generator.go:1166`)收集要内联的 `<script>` 定义时用的是同一个 `isScriptAttribute`,同样不折叠大小写。实测 `<button OnClick={ onClick() }>` 渲染出 `OnClick="__templ_onClick_657d()"` 却**没有**配套的 `<script>function __templ_onClick_657d(){…}</script>`(而 `onClick` 有),页面调用一个不存在的函数。本项目把这层定义留给 T6.2,到时同样按前缀判定。
  - **差分校验**:Go 探针(`templ.ComponentScript{Call: templ.SafeScript(...)}` 手工构造,绕开 script 块)把四种模板形状渲染一遍,逐字节作为 golden 断言:两个 `onClick` / `onMouseover`、`hx-on::click` + `onclick` 两个按钮、两个常量按钮、以及反例 `OnClick` + `data-on`(值用 `a<b`,确认走转义)。另用 `templ.ResolveAttributeValue` 直接确认了那条不转义的 `case ComponentScript`,以及 `OnClick={ script() }` 缺 `<script>` 定义的现象。
  - golden:`golden/script/`(四个模板),其中的 call 字符串按 templ `SafeScript` 的产物手写 —— script 块本身留给 T6.2,golden 只钉属性侧规则。已在 `cli/checked_in_wbtest.mbt` 登记。
  - `moon check` 零警告;`moon test` **376 passed / 0 failed**(较 T4.5 的 368 多出 8:生成器 3 + golden 5)。
- [x] **T4.7** 布尔表达式属性 `name?={ expr }` — 假值时整个属性消失 · 前置 T3.1 · S
  - 语法在 templ 那边是 `boolExpressionStart = Or("?={ ", "?={")`(`parser/v2/elementparser.go:279`):**属性名先解析**,`?` 不在属性名字符集里(本项目 `is_attr_name_char` 同样不含 `?`),所以 `a?={ x }` 读出来是名字 `a` 加一个 `?=`。本项目解析器原先在这条分支上直接抛 "boolean expression attributes are not supported yet",本次换成 `BoolExpression(name, value)` 这一支。
  - 生成形状照抄 templ `writeBoolExpressionAttribute`(`generator.go:1245`):**只把属性名包进 if**,值不参与 ——
    ```
    if <expr> {
      w.write_string(" name")
    }
    ```
    有趣的是**空格属于分支内**,所以 `if` 之前的字面量跑到标签名就断了(`"<hr"`),`if` 之后的字面量从下一个属性(或 `>`)接着写。这也说明 `RangeWriter` 的字面量攒批必须被 `if` 打断:实现上先 `write_indent(level, "if … {\n")`(它会 flush 掉挂起的字面量),再 `write_literal(level + 1, " name")`,再 `write_indent(level, "}\n")` —— 第三句按**字面量自己记的 level**(`+1`)缩进,不然会写到 if 外面去。
  - 解析器的错误面收窄成一条:`?` 之后必须是 `={`。`<div a?{ x }>` / `<div a?="x">` 报 "a boolean expression attribute is written `a?={ expr }`";`<div a?={ x ></div>` 仍走表达式扫描器的 "unterminated expression"。生成器另有一条防御:表达式为空的 `x?={  }` 直接报错(与 `name={ }` 同样处理)。
  - `mentions_in_attrs` 一并扩到三种带表达式的形态(`Expression` / `Spread` / `BoolExpression`),否则 `a?={ on }` 里的 `on` 不算被读。
  - **差分校验**:真 templ 渲染 `templ BoolAttrs(on bool)`(即 `test-html` 里那三行 `<hr>`,把 `true` / `false` 换成参数与 `!on`)两个分支,输出分别是 `<hr noshade><hr optionA optionB optionC="other"><hr noshade>` 与 `<hr><hr optionA optionC="other" optionD><hr noshade>`;golden 断言逐字节相同(含 `hr` 是块级元素、元素之间不留空格这条)。
  - golden:`golden/bool_expression/`,移植 `generator/test-html` 里带 `?={}` 的三行;两个分支各断言一次。已在 `cli/checked_in_wbtest.mbt` 登记。
  - `moon check` 零警告;`moon test` **383 passed / 0 failed**(较 T4.6 的 376 多出 7:解析器 1 + 生成器 4 + golden 2)。
- [x] **T4.8** 条件属性 `if expr { attrs } else { attrs }` — 两个分支各有快照 · 前置 T3.4、T3.1 · M
  - 与 `?={}` 的区别是**整块**由运行期决定:分支里放的不是一个属性,而是一整个属性列表。templ 那边是 `parser/v2/conditionalattributeparser.go`,`peekPrefix` 认的是 `"if "`(**带空格**),`if="x"` 仍是叫 `if` 的普通属性 —— 这条照搬,所以本项目的派发是 `src.has_prefix("if ")`,优先于 `parse_named_attribute`,而不是按属性名匹配。
  - **块的头部不能直接复用 `open_block`**,两条规则都不一样:(1) templ 用 `goexpression.If` 读头部,要求 `{` 与条件**同行**,`if p\n{` 报 "unexpected newline, expecting { after if clause";而 `open_block` 明确允许换行(Phase 2 里是照 templ 的 `for` / `if` 语句块写的)。(2) 反过来,`{` 之后的换行在 `open_block` 里是**必需**的(`take_block_newline`,因为块体是节点),而属性块里是可选的 —— 整条分支写在一行上 templ 也收。所以另写了 `open_attribute_block`:条件里出现换行即报错(**在 `trim_space` 之前查**,否则行尾那个换行会被裁掉、`if p\n{` 反而过检,这是实现时实际踩到的一处),`{` 之后的空白照常吞掉。
  - 生成形状照抄 templ `writeConditionalAttribute`(`generator.go:1449`):`if <expr> {` / 分支属性 +1 缩进 / `} else {` / 分支属性 +1 缩进 / `}`。templ 那里分支体是递归 `writeElementAttributes(indentLevel, elementName, attr.Then)`,**元素名一并传进去** —— 所以 `<a if on { href={ u } }>` 里那个 `href` 照样走 URL 白名单。本项目同样把 `element` 递归传下去,单测 `a` 的 `href={ u }` 断言生成 `@rt.sanitize_url(u)` 而不是默认的 `@rt.resolve_attribute_value`。
  - **出错面**(都对照真 templ 验证过):`else if` 是真 templ 的坑 —— 它把 `else` 读成一个**属性**,`<div if p { class="a" } else if q { class="b" }>` 在 `p` 为真时渲染出 `<div class="a" else>`(多一个叫 `else` 的裸布尔属性,再加一段 `if !p`)。这里直接报错("an attribute block has no `else if`")而不是照抄这个产物。空分支(templ:"invalid content or no attributes were found in the if block")、缺 `}`(报错点收在 `>`/`/>`/EOF 上,而不是漏给"expected attribute name")同样各有一条。
  - `mentions_in_attrs` 再扩一支:`Conditional` 的条件与两个分支都要看,否则 `if on { class={ a } }` 里的 `on` / `a` 会被误报成未用参数(`ignore(...)`)。
  - **差分校验**:真 templ 渲染同一模板(六个元素:单独 `if`、`if/else`、分支里的表达式 URL 与常量 URL、夹在普通属性之间的条件属性、嵌套条件属性、`disabled` 与 `type="button"` 两个分支)的两个分支,得到
    - `on=true`:`<div><div class="on"></div><div class="on"></div><a href="/a?x=1">link</a><div id="x" class="yes" data-k="v"></div><div class="a" title="t"></div><button disabled>b</button></div>`
    - `on=false`:`<div><div></div><div class="off"></div><a href="/b">link</a><div id="x" data-k="v"></div><div></div><button type="button">b</button></div>`
    golden 逐字节断言这两串;生成文件的形状(分支缩进、字面量在 `if` 处断开、嵌套条件属性多一层)也与 templ 生成的 Go **逐行同构**。
  - golden:`golden/condition/`(模板即上面那六个元素)。已在 `cli/checked_in_wbtest.mbt` 登记。
  - `moon check` 零警告;`moon test` **400 passed / 0 failed**(较 T4.7 的 383 多出 17:解析器 10 + 生成器 5 + golden 2)。

---

## Phase 5 — 工具链与打磨(达成 M4)

- [x] **T5.1** 诊断信息带 文件:行:列 — 模板语法错误时 CLI 输出可点击定位的位置 · 前置 T2.6 · M
  - 位置换算放在 `parser/error.mbt` 的 `line_column(source, offset)`,因为 `ParseError.offset` 就是解析器自己的游标;CLI 只负责拼成 `file:line:column: message`。**offset 的单位是 UTF-16 code unit**(`StringView::length` 的计数单位,也是 MoonBit `String` 的下标单位),不是字节,也不是字符数 —— 注释里原先写的 "byte-free character offset" 已改正。
  - 行按 `\n` 记,列按 **Unicode 字符**数(代理对算一列),所以中文与 emoji 之后的列号与编辑器看到的一致;越界 offset 分别夹到文件头/文件尾,而不是报错。`\r` 不单独断行(`\r\n` 里的 `\r` 算前一列的一个字符),与主流编辑器一致。
  - CLI 测试通过白盒用例 `cli/diagnostic_wbtest.mbt` 钉住输出文本:把 `generate_file` 里的读文件与生成拆成 `generate_file` + 私有的 `generate_source(input, source)`,后者让测试可以把一段源码冠上文件名来跑,不必真去写坏文件。
  - 顺带确认既有错误点的偏移是构造起始处:未闭合元素报在 `<div>` 的 `<` 上(`2:3`),而不是在文件末尾。
  - `moon check` 零警告;`moon test` **408 passed / 0 failed**(较 T4.8 的 400 多出 8:parser 6 + cli 2)。
- [x] **T5.2** `moon-templ fmt` 子命令 — 复用 AST 的 `Write`,对已格式化文件**幂等** · 前置 T2.9 · L
  - 新包 **`formatter/`**:`format_source(source)` 只重写 `templ` 块,块与块之间的内容(注释、package 行、空行)按字节原样抄回 —— 解析器为此在 `Template` 上记录了 `start` / `end` 两个 UTF-16 偏移。
  - 规范化后的 AST 本来不保留空白,因此 `Element` 新增两个布局事实:`indent_attrs`(属性列表在源码里单独成行)与 `indent_children`(标签与子节点不在同一行)。这是唯一保留下来的源码布局信息,其余按固定规则重排(每层两空格)。格式化器只在**重新解析后空白不变**的位置断行,判断逻辑镜像 `normalizer` 的 `keeps_gap`。
  - **顺带的行为变化**:条件属性不再强制把整个属性列表拆成多行(删掉了 `has_conditional`)。单行的 `if cond { a } else { b }` 保持单行,多行列表里的条件属性展开成嵌套块 —— 否则 `golden/condition/condition.templ` 无法是格式化不动点。
  - **修掉一个真实 bug**:相邻语句被粘成 `}for` / `}match`。断行安全性此前把 `If`/`For`/`Match` 当内联节点(`is_inline` 的口径),于是认为断行会凭空多出空格;实际上语句的尾随空白归列表所有,非 block 列表会丢掉它。改成与 `normalizer` 的 `leaves_trailing_space_to_list` 同一口径后恢复正常。
  - 三道语料护栏 `cli/format_wbtest.mbt`(遍历 13 个已入库模板):已格式化文件**不动点**、二次格式化**幂等**、格式化前后的**生成产物逐字节相同**。另有 `formatter/formatter_test.mbt` 9 条精确输出断言(缩进、语句、调用、属性、raw element、自闭合、接收者、块间文本、无模板文件)与 4 条 CLI `fmt` 用法/错误测试。
  - `raw element`(`<style>` / `<script>`)的内容原样写出、不重新缩进,因为那段内容对模板语法不可见;`moon check` 零警告;`moon test` **424 passed / 0 failed**(较 T5.1 的 408 多出 16:formatter 9 + CLI fmt 4 + 语料 3)。
- [x] **T5.3** `--watch` 热生成 — 改 `.templ` 后自动重新生成 · 前置 T3.9 · M
  - 用法:`moon-templ generate --watch <dir>/...`。先整树生成一遍,再每 250 ms 取一次 `Snapshot`(路径 → 文件内容),只重新生成**新增或内容变化**的文件;坏模板只报错、不退出循环,下次改动还能继续。
  - 轮询而不是操作系统事件:树很小,读一遍的成本远低于生成;好处是不用为每个平台写文件监听。快照与差异计算(`snapshot` / `Snapshot::changed`)是纯函数,直接单测,不依赖计时。
  - **计时只能落在 native**:MoonBit 的 `@sys` 与 `moonbitlang/x` 都没有 sleep,用 C FFI 绑 `usleep`;`cli/moon.pkg` 用 `options(targets:)` 把实现分成 `watch_native.mbt` 与 `watch_other.mbt`,后者在进入循环前就明确拒绝:"watch mode needs the native target"。这也意味着 `moon run cmd/main -- generate --watch ...` 需加 `--target native`。
  - 参数解析顺带升级:`generate` 现在接受选项,未知选项(如 `--frobnicate`)报错退出;两个路径仍然算用法错误。
  - 实测:在暂存目录起 watcher,改 `hello.templ` 的文案,一个轮询周期内 `hello_templ.mbt` 就带上了新文本并重启进程验证了 native 构建;wasm-gc 下的拒绝路径退出码为 1。`moon check`(wasm-gc 与 native)零警告;`moon test` **428 passed / 0 failed**(较 T5.2 的 424 多出 4)。
- [ ] **T5.4** 零警告 CI 门禁 — CI 断言生成产物编译时**无警告**(port-research §3.2.1 的五类)· 前置 T2.16 · S
- [ ] **T5.5** 文档与示例完善 — 双语文档;pre-build 接线示例;与 templ 的差异清单 · 前置 T3.9 · M

---

## Phase 6 — 可选 / 远期

不在 MVP 范围内,闲余时间有余力再做。

- [ ] **T6.1** `css` 块 + `ComponentCSSClass`(SHA-256 命名)· 前置 T4.2 · L
- [ ] **T6.2** `script` 块 + `ComponentScript` 集成 · 前置 T4.6 · L
- [ ] **T6.3** LSP(补全、跳转、诊断)· 前置 T5.2 · L
- [ ] **T6.4** `moon-templ sync`:自动改写 `moon.pkg` 的 `dev_build` 规则,缓解逐文件声明的 DX 痛点 · 前置 T3.9 · M
- [ ] **T6.5** templ → moon-templ 迁移工具 · 前置 T3.6 · M

---

## 里程碑

| 里程碑 | 定义 | 由哪个任务达成 |
|---|---|---|
| **M1 骨架打通** | `hello.templ` → 生成 → 编译 → 运行,HTML 输出逐字节正确 | T2.15 |
| **M2 MVP 可用** | 能写真实页面:布局 + 循环 + 条件 + children + 组件调用 | T3.10 |
| **M3 属性完整** | `class` / `style` / URL 白名单 / 事件属性全部按 templ 语义处理 | T4.8 |
| **M4 工具链完整** | `generate` / `fmt` / `watch` + 可定位的诊断信息 | T5.5 |

### 关键路径

```
runtime:T0.3 → T1.1 → T1.2 → T1.3 → T1.4          ✅ 已完成

Phase 2 主链:
  T0.5 → T2.1 → T2.6 → T2.9 → T2.11 → T2.12 → T2.13 → T2.14 → T2.15 ★M1

Phase 2 供给(喂给主链):
  T2.2  表达式扫描  ─────→ T2.13
  T2.3  元素解析    ─────→ T2.12
  T2.7 → T2.8 字面量 ────→ T2.11
  T2.4  属性解析    ─────→ T3.1(T3 才用上)
  T2.5  空白归一化  ─────→ T2.12
```

---

## 测试策略

- **主线用** `moon test` **快照测试**:`moon test --update` 刷新快照,和 templ 的 golden 目录思路一致。
- **稳定结果用断言测试**:转义表、空白折叠这类"定义明确、不该变"的,用 `assert_eq`;结构化调试输出用 `debug_inspect`,不要为了调试去 derive `Show`。
- **golden 基线直接移植 templ 的目录**(源码在 `/Users/daqing/go/pkg/mod/github.com/a-h/templ@v0.3.1070/`):

| templ 目录 | 覆盖 | 由哪个任务移植 |
|---|---|---|
| `generator/test-text-whitespace` | 文本空白折叠(最容易踩坑) | T2.5 |
| `generator/test-whitespace-around-go-keywords` | 关键字周围空白 | T2.5 |
| `generator/test-if` / `test-for` / `test-call` | 控制流与组件调用 | T3.11 |
| `generator/test-attributes` 系 | 属性特殊语义 | T4.3 – T4.8 |
| `examples/hello-world-ssr` | 最简全链路 | T2.15 |

---

## 明确不做(避免闲余时间跑偏)

- **不做 v1 的 `{% ... %}` 语法** —— 直接报错。
- **不实现非转义字符串输出语法** —— templ v2 里根本不存在,`{! expr }` 是已废弃的组件调用;唯一出口是 `@rt.raw(...)`。
- **不做 `context.Context` 的等价物** —— 用显式 `RenderCtx`(port-research §2)。
- **MVP 不支持 `{ expr, expr }` 多值语义** —— 只支持单表达式。
- **不引入 parser combinator 库** —— 用 `StringView` 解构式写法(port-research §6)。

---

## 已知的返工风险

| 风险 | 影响 | 何时会暴露 |
|---|---|---|
| T0.3 错误模型选错 | runtime 全部签名 + 所有生成代码都要改 | ✅ 已按"无 raise"落地,若要改回带 `raise`,T1 的 runtime 与全部单测需重写 |
| 空白归一化实现不完整 | T2.5 之后所有 golden 快照都要重刷 | ✅ 已用 748 组差分用例对齐(port-research §3.6);后续新增节点类型时记得同步补差分表 |
| 表达式扫描器边界不全 | 罕见的模板写法解析出错,定位困难 | T2.2 的单测要一次做足 |
| `pre-build` 逐文件声明 | 用户每加一个模板都要改 `moon.pkg` | 用 T6.4 缓解,或用 T0.2 选"提交产物"绕开(已选) |

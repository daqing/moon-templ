# moon-templ 实施任务清单

配套文档:[port-research.md](./port-research.md)(可行性调研与设计依据)
拆分日期:2026-10-17
目标:把 `a-h/templ` 的模板引擎在 MoonBit 中重新实现

**进度:31 / 58**

---

## 怎么用这份清单

- **每个任务前的复选框就是进度表。** 任务完成时把 `[ ]` 改成 `[x]`,并同步更新顶部的进度计数。**这一步是自动的** —— 每完成一个任务,当即打钩,不要攒着事后补。
- **任务粒度按"闲余时间一次坐下能完成"来切**,规模标注:S ≈ 1 小时内,M ≈ 2–3 小时,L ≈ 半天以上(建议再拆)。各阶段汇总:

  | 阶段 | 任务数 | 已完成 | 剩余 L |
  |---|---|---|---|
  | T0 决策与准备 | 5 | 5 | 0 |
  | T1 runtime 地基 | 5 | 5 | 0 |
  | T2 parser + generator 骨架 | 19 | 19 | 0 |
  | T3 MVP 完整 | 11 | 2 | 0 |
  | T4 属性特殊语义 | 8 | 0 | 0 |
  | T5 工具链与打磨 | 5 | 0 | 1(T5.2) |
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
- [ ] **T3.3** `{ children... }` + children 前导的三级发射规则 — 按 port-research §3.2 的表分级发射(避免 `unused_value`);单测验证 children **不透传**到孙子组件 · 前置 T3.2 · M
- [ ] **T3.4** `if` / `else if` / `else` — 条件原文抄进产物交给 MoonBit 编译器校验;校验 `{` 后必须换行 · 前置 T2.15 · M
- [ ] **T3.5** `for`:C 风格与 `for..in` 两种形式 — 两种形式各有快照;注意 MoonBit C 风格 for 写 `i = i + 1` · 前置 T3.4 · M
- [ ] **T3.6** 控制流分支:`match`(T0.1 已定,不用 Go 风格 `switch`)— 快照测试;需支持解构模式 `Some(x) => { ... }` · 前置 T3.5 · M
- [ ] **T3.7** `{ attrs... }` spread — 生成 `@rt.render_attributes` 调用 · 前置 T3.1 · M
- [ ] **T3.8** `{{ code }}` 原样写入函数体 — 单测:`{{ let x = 1 }}` 在产物中按 `let` 出现 · 前置 T2.15 · S
- [ ] **T3.9** 目录扫描 + 批量生成(`generate ./...`)— 一条命令生成整目录;跳过无变化文件(等价 templ `-lazy`)· 前置 T2.14 · M
- [ ] **T3.10** **端到端 M2**:写一个真实页面 — 布局组件 + 循环 + 条件 + children + 跨包组件调用,输出正确 · 前置 T3.3、T3.5、T3.6 · M
- [ ] **T3.11** 移植 templ 条件/循环/调用 golden — `test-if` / `test-for` / `test-call` 目录转为 MoonBit 快照测试 · 前置 T3.6 · M

---

## Phase 4 — 属性特殊语义(达成 M3)

> templ 对四类属性有超出"输出键值对"的特殊处理(port-research §1.2)。这一阶段把语义补齐。

- [ ] **T4.1** runtime:`Attributes` / `RenderAttributes` — 单测:map 与 KV 数组两种输入 · 前置 T1.1 · M
- [ ] **T4.2** runtime:`CSSClasses` / `KV` — 单测:常量与表达式混合、空值剔除 · 前置 T4.1 · M
- [ ] **T4.3** `class` 属性特殊处理 — 表达式走 `CSSClasses`,常量值 join 消空白;对 templ golden 校验 · 前置 T4.2、T3.1 · M
- [ ] **T4.4** `style` 属性 sanitize — 对 templ golden 校验 · 前置 T4.1 · M
- [ ] **T4.5** URL 白名单:`a[href]` `link[href]` `form[action]` `object[data]` — **故意用 `javascript:` 输入,断言被拦截** · 前置 T4.1 · M
- [ ] **T4.6** 事件属性 `on*` / `hx-on:*` → `ComponentScript` — 输出 `.Call` 而非转义值 · 前置 T4.1 · M
- [ ] **T4.7** 布尔表达式属性 `name?={ expr }` — 假值时整个属性消失 · 前置 T3.1 · S
- [ ] **T4.8** 条件属性 `if expr { attrs } else { attrs }` — 两个分支各有快照 · 前置 T3.4、T3.1 · M

---

## Phase 5 — 工具链与打磨(达成 M4)

- [ ] **T5.1** 诊断信息带 文件:行:列 — 模板语法错误时 CLI 输出可点击定位的位置 · 前置 T2.6 · M
- [ ] **T5.2** `moon-templ fmt` 子命令 — 复用 AST 的 `Write`,对已格式化文件**幂等** · 前置 T2.9 · L
- [ ] **T5.3** `--watch` 热生成 — 改 `.templ` 后自动重新生成 · 前置 T3.9 · M
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

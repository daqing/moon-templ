# moon-templ 实施任务清单

配套文档:[port-research.md](./port-research.md)(可行性调研与设计依据)
拆分日期:2026-10-17
目标:把 `a-h/templ` 的模板引擎在 MoonBit 中重新实现

---

## 怎么用这份清单

- **任务粒度按"闲余时间一次坐下能完成"来切**,规模标注:S ≈ 1 小时内,M ≈ 2–3 小时,L ≈ 半天以上(建议再拆)。
- **每个任务独立可交付。** 做完一个就 commit 一个,commit message 以任务号开头,例如 `T2.3: parse element open/close tags`。进度用 `git log --oneline` 追,不需要在本文档里维护状态列。
- **任何一步做完,仓库必须保持绿色**(`moon check` + `moon test` 通过)。宁可任务不做完,不要留半截的坏状态 —— 下次坐下时你才能立刻继续。
- **提交在 `develop` 分支上做**,不要直接在 `main` 上提交。
- **`T0.x` 是决策门,阻塞下游。** 先花十分钟把四个决策定下来,否则后面的 runtime 签名会返工。
- 拿不准选哪个任务时,挑**规模 S 且前置已满足**的;L 的任务留到有整块时间时做。

### 规模图例

| 标记 | 含义 |
|---|---|
| S | 一次坐下(≤1 小时) |
| M | 2–3 小时 |
| L | 半天以上,建议再拆 |

---

## Phase 0 — 决策门与工程准备(先做,阻塞下游)

**T0.1 – T0.4 是决策门**,在调研阶段有意留空,需你拍板。每项定下来后把结论写回 `port-research.md` §8 与 §4。

| ID | 任务 | 为什么阻塞 | 建议 | 规模 |
|---|---|---|---|---|
| T0.1 | 控制流语法用 `switch` 还是 `match` | 决定 T3.6 的解析与代码生成,也决定能否逐字复用 templ 的 `.templ` 文件 | 用 MoonBit 原生 `match`,表达力更好;代价是迁移工具要改写 | S |
| T0.2 | 生成产物(`*_templ.mbt`)提交进仓库,还是纯构建钩子生成不提交 | 决定 T2.14 / T3.9 的 CLI 输出策略与 `.gitignore` | 提交(照搬 templ),绕开逐文件声明 `pre-build` 的 DX 痛点 | S |
| T0.3 | 错误模型:`-> Component`(无 `raise`)还是流式 `raise RenderError` | **决定 runtime 全部函数签名,两者 API 不兼容**;阻塞 T1.1 | MVP 用无 `raise`,先跑通 | S |
| T0.4 | 扩展名沿用 `.templ` 还是换 `.mtpl` | 影响全仓库文件名与文档 | 沿用 `.templ`,便于对照 templ 文档 | S |
| T0.5 | 建仓库骨架:四个包目录 + 各自 `moon.pkg` + 包间依赖 | 后续所有任务都往里填;不是决策,是纯体力活 | 按 port-research §6 的 `runtime/` `parser/` `generator/` `cmd/main/` 划分;验收标准是 `moon check` 通过且 `moon run cmd/main` 能打印 | S |

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
runtime:T0.3 → T1.1 → T1.2 → T1.3 → T1.4

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

## Phase 1 — runtime 地基

> 原型已在调研阶段于 `/tmp` 中实测通过(见 port-research §3.1),本阶段是**把它落地到仓库并补测试**。

| ID | 任务 | 完成标准 | 前置 | 规模 |
|---|---|---|---|---|
| T1.1 | 落地 `Component` / `RenderCtx` / `component()` / `with_children` | 单测:嵌套两层组件,children 传到正确的那一层 | T0.3, T0.5 | S |
| T1.2 | `escape` 固定转义表 + `write_escaped` | 单测覆盖 `&` `'` `<` `>` `"` 五条,与 port-research §1.4 表格逐字节比对 | T1.1 | S |
| T1.3 | `write_any[T : Show]` 泛型输出 + `raw()` | 单测:`String`/`Int`/`Double`/`Bool` 输出正确;`raw` 不转义 | T1.2 | S |
| T1.4 | `impl Show for Component` + `extend Component with Show::{to_string, output}` | `moon check` 不出现 `implicit_impl_as_method` 警告(见 port-research §3.2.1) | T1.3 | S |
| T1.5 | runtime 边界测试补齐 | 空字符串、已是 HTML 实体的输入(`&amp;` 会被再转义)、多字节 UTF-8、超长字符串 | T1.4 | S |

---

## Phase 2 — parser + generator 骨架(打通 M1)

> 本阶段的唯一目标:让**最简单的模板**端到端跑起来。有了这条"行走骨架",后面每个特性都是往已知结构里填空。

| ID | 任务 | 完成标准 | 前置 | 规模 |
|---|---|---|---|---|
| T2.1 | AST 定义 `parser/types.mbt` | 先只覆盖 MVP 节点;**跨包可见的类型必须 `pub(all) enum`**(否则 E4036);derive(Debug, Eq) | T0.5 | M |
| T2.2 | `{ expr }` 花括号配平扫描器 | 单测:嵌套 `()` `[]` `{}` 正确;字符串内的 `}`、注释内的 `}`、rune 字面量均不误判 | T2.1 | M |
| T2.3 | 文本节点 + 元素开闭标签解析 | 单测:`<div></div>`、自闭合标签、大小写、元素名 charset | T2.2 | M |
| T2.4 | 属性解析 v1:静态 `name="v"`、三种引号、裸布尔属性 | 单测覆盖 `"` `'` 无引号三种形式 | T2.3 | M |
| T2.5 | 空白归一化 v1(块级元素判定 + 折叠) | 移植 templ `generator/test-text-whitespace` 的 golden 用例 | T2.3 | M |
| T2.6 | 文件级切分:`templ` 块识别 + 签名抽取 | 单测:无参、带参、方法形式(`templ (d Data) M()`);签名用"扫描到 depth-0 `{`"取原文 | T2.1 | M |
| T2.7 | `RangeWriter` 两态写入(累积字面量 vs 写代码) | 单测:连续文本被合并成**一个** `write_string`;字面量下标全文件递增 | T0.5 | M |
| T2.8 | 字面量生成:MoonBit 字符串转义 | 单测:含 `"` `\` 换行 tab 的文本生成正确。**注意 `String::escape()` 自带首尾引号,别再包一层** | T2.7 | S |
| T2.9 | generator 骨架:`Generator` 结构 + 字面量下标/变量名两个计数器 + 组件函数头尾发射 | 对一个**空组件**产出可编译的骨架:`pub fn x() -> @rt.Component { @rt.component(fn(ctx, w) { }) }`,`moon check` 通过 | T2.6 | M |
| T2.10 | 节点分派表:AST 节点 → 各 handler 的有序分派 | 遇到未实现的节点类型报**明确的**错误(带节点名与位置),不是静默跳过或产出坏代码 | T2.9 | S |
| T2.11 | 字面量发射:把 `RangeWriter` 接进 generator | 单测:`<div>` + 文本 + `<span>` 合并成**一个** `write_string`,不是三次;字面量下标全文件递增 | T2.7, T2.8, T2.9 | M |
| T2.12 | 元素节点发射:起止标签、自闭合、void 元素 | 单测:`<div></div>` / `<br/>` / `<img src="x">` 三种产物都正确 | T2.3, T2.11 | M |
| T2.13 | 表达式节点发射:`{ expr }` → `@rt.write_any(w, expr)` | 单测:`Hello, { name }` 产物是**两段字面量夹一次** `write_any` | T2.2, T2.11, T1.3 | M |
| T2.14 | CLI 骨架:`moon-templ generate <file.templ>` 单文件 | `moon run cmd/main -- generate x.templ` 产出 `x_templ.mbt`。注意 `args[0]` 是构建产物路径,真实参数从 `args[1]` 起 | T2.13 | M |
| T2.15 | **端到端 M1**:手写 `examples/hello/hello.templ` 全链路跑通 | 生成 → `moon build` → 运行 → HTML 输出逐字节正确;写成可重复执行的集成测试 | T2.14 | S |
| T2.16 | 生成后内联 `@fmt.format` 规范化产物 | 产物格式规范、`///|` 块分隔齐全(port-research §6) | T2.15 | S |

---

## Phase 3 — MVP 完整(达成 M2)

| ID | 任务 | 完成标准 | 前置 | 规模 |
|---|---|---|---|---|
| T3.1 | 表达式属性 `name={ expr }` | 生成 `resolve_attribute_value` 调用;快照测试 | T2.4, T2.15 | M |
| T3.2 | 组件调用 `@expr` / `@expr { }` | 生成 `.with_children(...).render(...)`;校验 `@` 前必须有空白 | T3.1 | M |
| T3.3 | `{ children... }` | 生成 `ctx.children.render(ctx, w)`;单测验证 children **不透传**到孙子组件 | T3.2 | S |
| T3.4 | `if` / `else if` / `else` | 条件表达式原文抄进产物交给 MoonBit 编译器校验;校验 `{` 后必须换行 | T2.15 | M |
| T3.5 | `for`:C 风格与 `for..in` 两种形式 | 两种形式各有快照;注意 MoonBit C 风格 for 写 `i = i + 1` | T3.4 | M |
| T3.6 | 控制流分支:按 **T0.1** 决定实现 `match` 或 `switch` | 快照测试 | T3.5 | M |
| T3.7 | `{ attrs... }` spread | 生成 `@rt.render_attributes` 调用 | T3.1 | M |
| T3.8 | `{{ code }}` 原样写入函数体 | 单测:`{{ let x = 1 }}` 在产物中按 `let` 出现 | T2.15 | S |
| T3.9 | 目录扫描 + 批量生成(`generate ./...`) | 一条命令生成整目录;跳过无变化文件(等价 templ `-lazy`) | T2.14 | M |
| T3.10 | **端到端 M2**:写一个真实页面 | 布局组件 + 循环 + 条件 + children + 跨包组件调用,输出正确 | T3.3, T3.5, T3.6 | M |
| T3.11 | 移植 templ 条件/循环/调用 golden | `test-if` / `test-for` / `test-call` 目录转为 MoonBit 快照测试 | T3.6 | M |

---

## Phase 4 — 属性特殊语义(达成 M3)

> templ 对四类属性有超出"输出键值对"的特殊处理(port-research §1.2)。这一阶段把语义补齐。

| ID | 任务 | 完成标准 | 前置 | 规模 |
|---|---|---|---|---|
| T4.1 | runtime:`Attributes` / `RenderAttributes` | 单测:map 与 KV 数组两种输入 | T1.1 | M |
| T4.2 | runtime:`CSSClasses` / `KV` | 单测:常量与表达式混合、空值剔除 | T4.1 | M |
| T4.3 | `class` 属性特殊处理 | 表达式走 `CSSClasses`,常量值 join 消空白;对 templ golden 校验 | T4.2, T3.1 | M |
| T4.4 | `style` 属性 sanitize | 对 templ golden 校验 | T4.1 | M |
| T4.5 | URL 白名单:`a[href]` `link[href]` `form[action]` `object[data]` | **故意用 `javascript:` 输入,断言被拦截** | T4.1 | M |
| T4.6 | 事件属性 `on*` / `hx-on:*` → `ComponentScript` | 输出 `.Call` 而非转义值 | T4.1 | M |
| T4.7 | 布尔表达式属性 `name?={ expr }` | 假值时整个属性消失 | T3.1 | S |
| T4.8 | 条件属性 `if expr { attrs } else { attrs }` | 两个分支各有快照 | T3.4, T3.1 | M |

---

## Phase 5 — 工具链与打磨(达成 M4)

| ID | 任务 | 完成标准 | 前置 | 规模 |
|---|---|---|---|---|
| T5.1 | 诊断信息带 文件:行:列 | 模板语法错误时 CLI 输出可点击定位的位置 | T2.6 | M |
| T5.2 | `moon-templ fmt` 子命令 | 复用 AST 的 `Write`,对已格式化文件**幂等** | T2.9 | L |
| T5.3 | `--watch` 热生成 | 改 `.templ` 后自动重新生成 | T3.9 | M |
| T5.4 | 零警告 CI 门禁 | CI 断言生成产物编译时**无警告**(port-research §3.2.1 的四类) | T2.16 | S |
| T5.5 | 文档与示例完善 | 双语文档;pre-build 接线示例;与 templ 的差异清单 | T3.9 | M |

---

## Phase 6 — 可选 / 远期

不在 MVP 范围内,闲余时间有余力再做。

| ID | 任务 | 前置 | 规模 |
|---|---|---|---|
| T6.1 | `css` 块 + `ComponentCSSClass`(SHA-256 命名) | T4.2 | L |
| T6.2 | `script` 块 + `ComponentScript` 集成 | T4.6 | L |
| T6.3 | LSP(补全、跳转、诊断) | T5.2 | L |
| T6.4 | `moon-templ sync`:自动改写 `moon.pkg` 的 `dev_build` 规则,缓解逐文件声明的 DX 痛点 | T3.9 | M |
| T6.5 | templ → moon-templ 迁移工具 | T3.6 | M |

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
| T0.3 错误模型选错 | runtime 全部签名 + 所有生成代码都要改 | T1.1 之后越晚越贵,**务必先定** |
| 空白归一化实现不完整 | T2.5 之后所有 golden 快照都要重刷 | T2.5 完成后尽早跑满 templ 的 whitespace 用例 |
| 表达式扫描器边界不全 | 罕见的模板写法解析出错,定位困难 | T2.2 的单测要一次做足 |
| `pre-build` 逐文件声明 | 用户每加一个模板都要改 `moon.pkg` | 用 T6.4 缓解,或用 T0.2 选"提交产物"绕开 |

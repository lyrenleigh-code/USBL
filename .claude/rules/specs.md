---
paths:
  - specs/**
  - plans/**
---

# 任务管理规则（模块化，2026-04-15 起）

## Spec 卡

- **一个模块 = 一张 spec 卡**，放在 `specs/active/<MOD>-<name>.md`
- 命名规则：`<模块编号>-<短英文名>.md`，例如 `A1-signal-range.md`、`H3-transponder.md`、`M2-electroacoustic-consistency.md`
- 模块编号体系：
  - **A1–A6** 算法线 / **H1–H6** 硬件线 / **M1–M5** 测量校准线 / **S1–S2** 系统线
  - 新增模块需在 `TODO.md` 和 `CLAUDE.md` 同步登记，编号递增
- 新建 spec 卡前先读 `specs/_template.md` 模板

## Spec 必填字段

Frontmatter：`type: spec` / `module` / `created` / `updated` / `status` / `owner` / `tags`

正文固定七字段：
1. **目标** — 一句话说明交付什么
2. **范围** — 包含 / 不包含
3. **输入接口** — 来自哪些模块 / 数据结构 / 参数
4. **输出接口** — 产出什么 / 供谁使用
5. **验收标准** — 可量化（checkbox 列表）
6. **依赖模块** — 上游/下游
7. **里程碑映射** — M?/HM?
8. **当前状态** — 已实现 / 部分实现 / 待开发 简述
9. **相关文献与页面** — wikilinks

## 状态流转

- `draft` → `in-progress` → `done` → 归档到 `specs/archive/`
- `blocked` 需在 spec 里说明阻塞原因与解除条件
- 状态变更必须同步 `TODO.md` 模块状态图例

## Plan 规则

- 非平凡模块实现前先写 plan：`plans/<MOD>.md`
- plan 内容：影响文件、实现步骤、测试策略、风险
- 完成后在 plan 顶部标注 `status: completed` 并附验证证据

## 归档与知识沉淀

- 模块完成后：spec 卡移至 `specs/archive/`、`TODO.md` 改 🟢
- 实现中产生的有价值结论用 `/promote` 回流 Hub
- 跨模块接口变更：两张卡的「接口」章节同步修改

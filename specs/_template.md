---
type: spec-template
created: 2026-04-15
---

# Spec 卡模板

> 复制本模板到 `specs/active/<MOD>-<name>.md` 作为模块 spec。

```markdown
---
type: spec
module: XX-name
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft | in-progress | done | blocked
owner: TBD
tags: [spec, <line>, <domain>]
---

# <MOD>: <模块中文名>

> 模块线：A/H/M/S
> 依赖：[[...]]
> 里程碑映射：M?/HM?

## 目标
一句话说明交付什么。

## 范围
- 包含：
- 不包含：

## 输入接口
来自哪些模块 / 数据结构 / 参数。

## 输出接口
产出什么 / 供谁使用。

## 验收标准
- [ ] 量化指标 1
- [ ] 量化指标 2

## 依赖模块
- 上游：
- 下游：

## 里程碑映射
- HM?/M?：...

## 当前状态
已实现 / 部分实现 / 待开发 — 简述。

## 相关文献与页面
- [[...]]
```

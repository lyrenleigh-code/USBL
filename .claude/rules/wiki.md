---
paths:
  - wiki/**
---

# Wiki 规则

- 所有 wiki 内容用**中文**撰写
- 每个新页面必须包含完整 frontmatter：`type`、`created`、`updated`、`tags`
- 每个新页面至少包含一个 `[[wikilink]]` 链接到相关页面
- 来源派生的结论必须引用对应的 source-summary 页（如 `[[yumin-2006-lr-usbl]]`）
- 不要把 raw/ 的原文搬入 wiki/，要**提炼和结构化**
- 修改 wiki/ 后**必须同步更新** `wiki/index.md`（条目+页面计数）和 `wiki/log.md`（操作记录）
- 存在矛盾信息时，使用 `> [!warning]` 标注，不要静默覆盖
- wiki 页面类型：concepts（概念）、topics（专题）、source-summaries（资料摘要）、comparisons（对比）、explorations（探索）

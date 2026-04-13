---
paths:
  - specs/**
  - plans/**
---

# 任务管理规则

- 每个任务一个 spec 文件，放在 `specs/active/`，命名：`YYYY-MM-DD-任务名.md`
- spec 必须包含：目标、原因、范围（涉及哪些 simulation/ 子目录）、非目标、验收标准
- plan 在 spec 确认后创建，放在 `plans/`，包含：影响文件、实现步骤、测试策略、风险
- 任务完成后 spec 移到 `specs/archive/`，plan 标注完成状态
- 实现完成后，有价值的跨项目结论用 `/promote` 回流 Hub

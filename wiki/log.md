# Wiki 操作日志

## 2026-04-13

- 初始化 wiki 目录结构，对齐 ohmybrain-core 模板
- 摄入 9 篇论文到 wiki/source-summaries/：
  - 喻敏(2006) → yumin-2006-lr-usbl.md
  - 丁杰(2020) → dingjie-2020-compact-usbl.md
  - 杨保国(2013) → yangbaoguo-2013-usbl-calibration.md
  - 郑翠娥 → zhengcuie-usbl-docking.md
  - 蘧振超(2024) → quzhenzhao-2024-usbl-precision.md
  - 黄健(2019) → huangjian-2019-lbl-usbl.md
  - 刘峰(2024) → liufeng-2024-passive-localization.md
  - 何旭涛 → hexutao-usbl-quad-array.md
  - 郭瑜(2024) → guoyu-2024-lie-group-nav.md
- 创建概念页 wiki/concepts/usbl-positioning.md
- 创建专题页 wiki/topics/usbl-literature-review.md（文献综述）
- 创建专题页 wiki/topics/lr-usbl-development-plan.md（研制计划）
- 修复 hook 脚本 check_raw_write.py（stdin JSON 协议 + exit(2) 阻断）
- 修复 hook 脚本 check_index_log_sync.py（exit(2) 阻断）
- 创建 /ingest skill（.claude/commands/ingest.md）
- 创建仪表盘 wiki/dashboard.md（模块状态、阶段进度、待办、里程碑）
- 创建知识地图 wiki/usbl-moc.md（信号链路、代码地图、知识层导航）
- 补全 .claude/rules/（raw、wiki、engineering、specs 四条路径规则）
- 补全 .claude/skills/（implement-task、ingest-source、lint-wiki、plan-task、promote-answer）

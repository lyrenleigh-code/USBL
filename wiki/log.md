# Wiki 操作日志

## 2026-04-15

- **架构整理方案 1 落地**：specs/active/ 分 A/H/M/S 四个子目录，19 张 spec 卡按线归位
- simulation/ 各子目录（config/core/doa/analysis）及根目录添加 README，标注模块归属
- dashboard.md 重写为**纯聚合视图**（不再重复存状态，只引用 TODO.md 和 spec 卡）
- lr-usbl-development-plan.md 移除 Phase 1 P0/P1/P2/P3 任务清单（迁移到 TODO.md），战略视图与执行视图分离
- CLAUDE.md 目录结构更新（specs/active/A|H|M|S 子目录）
- 确立"状态单一事实源"约定：TODO.md + spec frontmatter 是状态源，dashboard/plan 是引用
- 项目模块化重构（方案 B）：建立 19 个模块 spec 卡，落到 `specs/active/`
  - A 系列（算法 6）：A1 信号测距 / A2 DOA / A3 声速声线 / A4 iUSBL 坐标 / A5 多潜标 / A6 组合导航
  - H 系列（硬件 6）：H1 换能器 / H2 阵列 / H3 应答器 / H4 采集 / H5 结构水密 / H6 联调
  - M 系列（测量校准 5）：M1 阵型几何 / M2 电声一致性 / M3 安装偏差 / M4 在线重构 / M5 年度 SOP
  - S 系列（系统 2）：S1 仿真平台 / S2 试验平台
- 将原 A6 安装校准迁移到 M3（校准线独立）
- 重构 `TODO.md` 为模块索引（状态/里程碑/Spec 链接），原任务全部映射到对应模块
- 建立 `specs/archive/` 与 `plans/` 目录、`specs/_template.md` 模板

## 2026-04-14

- 更新 `wiki/topics/lr-usbl-development-plan.md`：
  - 四阶段 → 五阶段（增加组合导航阶段）
  - 新增"各阶段核心模块与文献来源"矩阵，关联 9 篇文献
  - 新增"重难点"章节：算法 7 个（iUSBL 变换、低 SNR DOA、相位模糊、声速建模、UCA 秩亏、校准、野值鲁棒）+ 硬件 4 个（10kHz 宽带换能器、阵元幅相一致性、多通道同步采样、耐压水密）
  - 风险表扩展为风险速查（带严重度标签）
  - 新增"硬件研制并行线（自研）"章节：HW-1~HW-6 工作分解、并行时间线、HM1~HM5 硬件里程碑
- 同步 index.md 描述与更新日期
- 新建 `wiki/topics/usbl-hardware-spec.md`：硬件自研专题页
  - HW-1 换能器 / HW-2 阵列 / HW-3 应答器 / HW-4 采集电子 / HW-5 结构水密 / HW-6 联调 详细指标与方案
  - 系统硬件拓扑图、BOM 雏形（自研/外协分类）、外协清单、打压+标定+温循测试流程
  - 硬件风险清单（换能器带宽、阵元一致性、时延抖动、供应链等 7 项）

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

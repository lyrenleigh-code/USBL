# USBL 自定位系统算法项目

> **Hub**: `D:\Claude\Ohmybrain` — 跨项目知识中心（查询领域知识/回流结论用 `/promote`）
> **模板**: `D:\Claude\ohmybrain-core` — 项目模板源

## 项目概述

基于超短基线(USBL)的水下自定位系统算法研发。系统利用已知位置潜标上的声学应答器，通过五元圆阵接收应答信号，测量斜距和DOA，反算自身平台位置。算法覆盖从信号检测到定位输出的全链路。

## 系统关键参数

- 中心频率: 10 kHz, 波长 λ = 15 cm
- 阵列: 五元均匀圆阵(UCA), 阵元间距 20 cm, d/λ = 1.33 (存在相位模糊)
- 最大作用距离: ≥ 10 km
- 定位精度: 优于斜距的 1%
- 定位模式: 逆向USBL自定位 (已知潜标位置, 求解自身位置)
- 信号体制: LFM, 带宽 4 kHz, 脉宽 100 ms
- 算法平台: PC (MATLAB原型 → C/C++产品化)

## 技术决策记录

- DOA主力算法: **ML两级搜索** (单快拍最优, 全局搜索天然解模糊)
- DOA辅助算法: **相位比较法** (交叉验证 + 残差质量指标)
- CBF作为解模糊粗估计基底
- 链路预算用**单程TL** (应答器模式, 应答器SL=185dB)
- 平面阵DOA解算: 只用xy分量做最小二乘, u_z由单位球约束恢复

## 目录结构

```
USBL/
├── CLAUDE.md                          # 本文件
├── TODO.md                            # 任务跟踪
├── raw/                               # 只读原始资料
│   └── papers/                        # 9 篇参考论文 PDF
├── wiki/                              # 项目知识层（14 页）
│   ├── index.md                       # 页面索引
│   ├── log.md                         # 操作日志
│   ├── dashboard.md                   # 项目仪表盘
│   ├── usbl-moc.md                    # 知识地图
│   ├── concepts/                      # 概念页
│   ├── topics/                        # 专题页（文献综述、研制计划）
│   └── source-summaries/              # 论文摘要（9 篇）
├── simulation/                        # MATLAB 仿真环境
│   ├── config/usbl_config.m           # 全局参数配置
│   ├── core/                          # 基础模块（阵列/信号/信道/坐标变换）
│   ├── doa/                           # DOA 估计算法（7 种）
│   ├── analysis/                      # 分析工具
│   ├── run_doa_comparison.m           # DOA 算法对比主脚本
│   ├── run_error_budget.m             # 误差分配主脚本
│   └── run_full_simulation.m          # 全链路信号级仿真
├── workflows/                         # 操作流程文档
│   ├── engineering/                   # 开发闭环（spec→plan→implement→validate）
│   └── knowledge/                     # 知识闭环（ingest→query→promote）
├── specs/                             # 任务 spec（active/ + archive/）
├── plans/                             # 实现计划
├── scripts/                           # 自动化脚本
├── .claude/                           # harness
│   ├── settings.json                  # hooks 配置
│   ├── rules/                         # 路径规则（raw/wiki/engineering/specs）
│   ├── commands/                      # 用户命令（/ingest, /promote）
│   └── skills/                        # 工作流技能
└── .obsidian/                         # Obsidian vault 配置 + 模板
```

## 两个闭环

### 知识闭环

```
raw/ → /ingest → wiki/ → query → /promote → Ohmybrain Hub wiki/
```

### 开发闭环

```
01-spec → 02-plan → 03-implement(产出三件套) → 04-validate(验证+同步+归档+commit)
```

## 自动化保障（Hooks）

| 时机 | 检查内容 | 脚本 |
|------|---------|------|
| PreToolUse（Edit/Write） | 阻断 raw/ 写入 | `scripts/check_raw_write.py`（stdin JSON + exit 2） |
| PostToolUse（Edit/Write） | Wiki 结构快速检查 | `scripts/lint_wiki.py --quick` |
| Stop | Wiki index/log 同步检查 | `scripts/check_index_log_sync.py` |
| Stop | 任务完整性验证 | `scripts/validate_task.py` |

## 路径规则（.claude/rules/）

| 规则 | 触发路径 | 核心约束 |
|------|---------|---------|
| raw.md | `raw/**` | 只读，知识产出写 wiki/ |
| wiki.md | `wiki/**` | 中文、frontmatter、必须同步 index+log |
| engineering.md | `simulation/**`, `specs/**`, `plans/**` | 先 spec 再 code，统一接口，附带测试 |
| specs.md | `specs/**`, `plans/**` | spec 命名规范，完成后归档 |

## 常用命令

| 命令 | 用途 |
|------|------|
| `/ingest` | 摄入 raw/ 资料到 wiki/（7 步流程） |
| `/promote` | 回流跨项目结论到 Hub（5 步流程） |
| `python scripts/lint_wiki.py` | Wiki 结构检查 |
| `python scripts/sync_index.py` | 同步 index 页面计数 |

## 代码规范

- 语言: MATLAB (仿真原型), 中文注释
- 所有参数集中在 `usbl_config.m`, 各模块通过 cfg 结构体引用
- DOA算法统一接口: `[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)`
- 角度约定: theta = 极角(0°=阵法线/下方), phi = 方位角(0°=前方/x轴)
- 坐标系: 阵面在xy平面, 法线沿z轴正方向(向下)
- 运行仿真前先 `addpath('config', 'core', 'doa', 'analysis')`

## 已知问题

| 问题 | 状态 | 说明 |
|------|------|------|
| `caxis` → `clim` | ✅已修复 | 新版MATLAB兼容 |
| ray_trace.m 极端剖面不收敛 | 🔶待修复 | 需加迭代保护 |
| 仿真未考虑多径 | 🔴待做 | 需加海面/海底反射模型 |

## 项目内导航

- **仪表盘**: `wiki/dashboard.md`
- **知识地图**: `wiki/usbl-moc.md`
- **文献综述**: `wiki/topics/usbl-literature-review.md`（9 篇论文）
- **研制计划**: `wiki/topics/lr-usbl-development-plan.md`（四阶段路线图）

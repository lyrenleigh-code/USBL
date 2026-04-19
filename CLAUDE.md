# USBL 自定位系统算法项目

> **Hub**: `D:\Claude\Ohmybrain` — 跨项目知识中心（查询领域知识/回流结论用 `/promote`）
> **模板**: `D:\Claude\ohmybrain-core` — 项目模板源

## 项目概述

基于超短基线(USBL)的水下自定位系统算法与硬件研发。系统利用已知位置潜标上的声学应答器，通过五元圆阵接收应答信号，测量斜距和DOA，反算自身平台位置。算法+硬件+标定三线并行，覆盖从信号检测到定位输出的全链路。

## 系统关键参数

- 中心频率: **12 kHz**（2026-04-19 从 10 kHz 更新，依据 [[neub-816-test-report-260102]] 9 项测试均在 12 kHz 频点）
- 波长 λ = 12.5 cm（c=1500 m/s）
- 阵列: **笼式五元立体阵**（4 立柱 + 1 中央 + 双盘支撑）
  - 阵型来源：工程图 [[five-element-transducer-assembly-drawing-vA]] + 垂直指向性非对称（180° 方向凹陷）独立佐证
  - 算法：`create_cage5.m` / `cfg.array.type = 'CAGE5'`；精确 5 阵元坐标待供应商 STEP/IGES 模型到手后填入
  - 立体阵下"相邻间距 20 cm"概念不再适用；`doa_phase_compare` 走 3D LS 分支
- 最大作用距离: ≥ 10 km
- 定位精度: 优于斜距的 1%
- 定位模式: 逆向USBL自定位 (已知潜标位置, 求解自身位置)
- 信号体制: LFM, 带宽 4 kHz, 脉宽 100 ms
- 算法平台: PC (MATLAB原型 → C/C++产品化)
- 接收灵敏度（实测）: **-200 dB re 1V/μPa**（8-16 kHz 内平坦，变化 <1 dB）
- 通道一致性（实测，12 kHz）：幅度 ±0.5 dB / 相位 ±3.6°，**M2 走软件校正**（实测数据已并入 M2 spec）

## 技术决策记录

- DOA主力算法: **ML两级搜索** (单快拍最优, 全局搜索天然解模糊)
- DOA辅助算法: **相位比较法** (交叉验证 + 残差质量指标)
- CBF作为解模糊粗估计基底
- 链路预算用**单程TL** (应答器模式, 应答器SL=185dB)
- 平面阵DOA解算: 只用xy分量做最小二乘, u_z由单位球约束恢复

## 模块划分（方案 B，2026-04-15 确立）

项目切分为 **19 个独立模块**，每个模块一张 spec 卡（`specs/active/<MOD>.md`），走 spec→plan→implement→validate 闭环。

| 线别 | 数量 | 说明 |
|------|------|------|
| **A 算法线** | 6 | 信号链/DOA/声速/坐标/融合/导航 |
| **H 硬件线**（自研） | 6 | 换能器/阵列/应答器/采集/结构/联调 |
| **M 测量校准线**（横切） | 5 | 阵型几何/电声一致性/安装/在线重构/年度 SOP |
| **S 系统线** | 2 | 仿真平台/试验平台 |

详细清单与状态见 `TODO.md` 模块索引；单模块细节见对应 spec 卡。

## 目录结构

```
USBL/
├── CLAUDE.md                          # 本文件
├── TODO.md                            # 模块索引总览（19 个模块）
├── raw/                               # 只读原始资料
│   └── papers/                        # 9 篇参考论文 PDF
├── wiki/                              # 项目知识层（15 页）
│   ├── index.md                       # 页面索引
│   ├── log.md                         # 操作日志
│   ├── dashboard.md                   # 项目仪表盘
│   ├── usbl-moc.md                    # 知识地图
│   ├── concepts/                      # 概念页
│   ├── topics/                        # 专题页（综述/计划/硬件 spec）
│   └── source-summaries/              # 论文摘要（9 篇）
├── specs/                             # 模块 spec 卡
│   ├── _template.md                   # spec 模板
│   ├── active/                        # 19 张 spec
│   │   ├── A/                         # 算法线 6 张
│   │   ├── H/                         # 硬件线 6 张
│   │   ├── M/                         # 测量校准线 5 张
│   │   └── S/                         # 系统线 2 张
│   └── archive/                       # 已完成模块
├── plans/                             # 实现计划（按模块组织）
├── simulation/                        # MATLAB 仿真（对应 A 系列 + S1）
│   ├── config/usbl_config.m
│   ├── core/                          # 基础模块（阵列/信号/信道/坐标变换）
│   ├── doa/                           # A2 DOA 套件
│   ├── analysis/                      # 误差分析
│   ├── run_doa_comparison.m
│   ├── run_error_budget.m
│   └── run_full_simulation.m
├── hardware/                          # 硬件设计（对应 H 系列，待建）
├── calibration/                       # 校准代码与 SOP（对应 M 系列，待建）
├── workflows/                         # 操作流程文档
│   ├── engineering/                   # 开发闭环（spec→plan→implement→validate）
│   └── knowledge/                     # 知识闭环（ingest→query→promote）
├── scripts/                           # 自动化脚本（wiki lint/sync/hooks）
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
01-spec (specs/active/<MOD>.md)
  ↓
02-plan (plans/<MOD>.md)
  ↓
03-implement (代码到 simulation/ | hardware/ | calibration/，含测试)
  ↓
04-validate (验证 + 更新 wiki + 归档 spec 到 specs/archive/ + commit)
```

**每个任务必须绑定一个模块编号**（A1/H3/M2 等），不挂空任务。

## 自动化保障（Hooks）

| 时机 | 检查内容 | 脚本 |
|------|---------|------|
| PreToolUse（Edit/Write） | 阻断 raw/ 写入 | `scripts/check_raw_write.py`（stdin JSON + exit 2） |
| PreToolUse（Edit/Write） | 阻断 `<private>` 标签外泄到 wiki/ 等公开路径 | `scripts/check_private_tags.py` |
| PostToolUse（Edit/Write） | Wiki 结构快速检查 | `scripts/lint_wiki.py --quick` |
| Stop | Wiki index/log 同步检查 | `scripts/check_index_log_sync.py` |
| Stop | 任务完整性验证 | `scripts/validate_task.py` |

### Hook Exit Code Strategy

| Exit | 含义 | 触发效果 |
|------|------|---------|
| **0** | 成功 / 优雅放行 | 继续执行，stdout 可见 |
| **1** | 非阻断错误 | stderr 显示给用户，继续执行 |
| **2** | 阻断错误 | stderr 喂回 Claude，阻止工具调用 |

**设计原则**：宽松优先（未知输入 exit 0 放行）；阻断谨慎（仅安全性/一致性被破坏时 exit 2，如 `check_raw_write` / `check_private_tags` / `check_index_log_sync`）；非致命提醒用 exit 0 + stdout。Windows Terminal 下大量非 0 exit 可能导致 tab 累积。

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

## 模块工作约定

- **动手前先定位模块**：查 `TODO.md` 找到模块编号（A*/H*/M*/S*），打开对应 spec 卡
- **spec 不足时补全**：状态为 🔴 draft 的 spec 卡可能字段待填，开始工作前先完善验收标准与接口
- **跨模块影响写进 spec**：修改 A2 导致 M2 校正表格式变化 → 两张卡的「接口」章节都要改
- **完成一个模块 = 把 spec 搬到 archive/ + 更新 TODO.md 状态**

## 代码规范

- 语言: MATLAB (仿真原型), 中文注释
- 所有参数集中在 `usbl_config.m`, 各模块通过 cfg 结构体引用
- DOA算法统一接口: `[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)`
- 角度约定: theta = 极角(0°=阵法线/下方), phi = 方位角(0°=前方/x轴)
- 坐标系: 阵面在xy平面, 法线沿z轴正方向(向下)
- 运行仿真前先 `addpath('config', 'core', 'doa', 'analysis')`

## 已知问题（归口到模块）

| 问题 | 模块 | 状态 |
|------|------|------|
| `caxis` → `clim` | A2 | ✅已修复 |
| ray_trace.m 极端剖面不收敛 | A3 | 🔶待修复（核心阻塞项） |
| 仿真未考虑多径 | S1 | 🔴待做 |
| iUSBL 逆向变换链路（文献空白） | A4 | 🔴核心阻塞，Phase 1 P0 |

## 项目内导航

- **仪表盘**: `wiki/dashboard.md`
- **知识地图**: `wiki/usbl-moc.md`
- **模块索引**: `TODO.md`（19 个模块状态速查）
- **文献综述**: `wiki/topics/usbl-literature-review.md`（9 篇论文）
- **研制计划**: `wiki/topics/lr-usbl-development-plan.md`（五阶段+硬件并行+11 重难点）
- **硬件 spec**: `wiki/topics/usbl-hardware-spec.md`（HW-1~HW-6 细节）

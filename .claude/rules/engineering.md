---
paths:
  - simulation/**
  - hardware/**
  - calibration/**
  - specs/**
  - plans/**
---

# 工程代码规则

## 模块绑定（强约束）

- **每个代码任务必须绑定一个模块编号**（A1/A2/.../H1/.../M1/.../S1/S2），见 `TODO.md` 模块索引
- 动手前先打开 `specs/active/<MOD>.md`，确认目标/接口/验收
- spec 状态为 `draft` 时，先补全验收标准与接口定义再动手
- 非平凡实现必须先在 `plans/<MOD>.md` 写实现计划

## 代码组织（按模块线分目录）

- **A 系列（算法）→ `simulation/`**
  - `simulation/config/` — 全局参数（`usbl_config.m`）
  - `simulation/core/` — 基础模块（阵列、信号、信道、坐标变换）
  - `simulation/doa/` — A2 DOA 套件
  - `simulation/analysis/` — 误差分析
  - `simulation/nav/` — A6 组合导航（待建）
  - `simulation/fusion/` — A5 多潜标融合（待建）

- **H 系列（硬件）→ `hardware/`**（待建）
  - `hardware/<H*>/` — 每模块一子目录（原理图、PCB、仿真、选型报告）
  - 硬件仿真脚本（COMSOL/PZFlex/SPICE）也放对应模块下

- **M 系列（测量校准）→ `calibration/`**（待建）
  - `calibration/<M*>/` — SOP、标定脚本、校正表生成代码

- **S 系列（系统）→ `simulation/` 根目录**
  - `simulation/run_*.m` — 主脚本
  - Monte Carlo 框架、场景库

- 新增子目录需在 `CLAUDE.md` 目录结构中登记

## 代码规范

- 所有参数集中在 `simulation/config/usbl_config.m`，各模块通过 `cfg` 结构体引用
- DOA 算法统一接口：`[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)`
- MATLAB 函数保持小而可测试，中文注释
- 代码变更必须附带测试脚本（`run_xxx.m` 或 `test_xxx.m`），或在 plan 里说明为何不需要
- 模块内部可任意重构；**跨模块接口变更**必须同步更新涉及模块的 spec 卡「接口」章节

## 闭环要求

- 模块接口或系统架构变化 → 同步更新 `wiki/`
- 模块完成 → spec 卡移至 `specs/archive/`、更新 `TODO.md` 状态
- 有跨项目价值的结论 → `/promote` 回流 Hub

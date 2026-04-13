---
paths:
  - simulation/**
  - specs/**
  - plans/**
---

# 工程代码规则

- 每个代码任务必须先有 `specs/active/` 下的 spec，非平凡实现必须先有 `plans/` 下的计划
- 代码在 `simulation/` 目录下组织，按功能分子目录：
  - `simulation/config/` — 全局参数配置
  - `simulation/core/` — 基础模块（阵列、信号、信道、坐标变换）
  - `simulation/doa/` — DOA 估计算法
  - `simulation/analysis/` — 分析工具
  - 新增子目录需在 CLAUDE.md 目录结构中登记
- 所有参数集中在 `simulation/config/usbl_config.m`，各模块通过 `cfg` 结构体引用
- DOA 算法统一接口：`[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)`
- MATLAB 函数保持小而可测试，中文注释
- 代码变更必须附带测试脚本（`run_xxx.m` 或 `test_xxx.m`），或说明为何不需要
- 当模块接口或系统架构变化时，同步更新 wiki/

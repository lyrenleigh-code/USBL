---
type: spec
module: S1-simulation-platform
created: 2026-04-15
updated: 2026-04-15
status: in-progress
owner: TBD
tags: [spec, system, simulation, monte-carlo]
---

# S1: 仿真平台

> 模块线：S（系统）
> 依赖：全部 A 系列、M 系列
> 里程碑映射：M1、M2

## 目标
统一的 MATLAB 仿真平台：场景库、信道模型、Monte Carlo 框架、误差注入。

## 范围
- 包含：场景库（6+ 场景，见 lr-usbl-development-plan）
- 包含：信道仿真（已有）、多径模型（待加）、噪声注入
- 包含：Monte Carlo 自动化框架（多场景并行）
- 包含：误差源独立注入（DOA/测距/姿态/阵型/安装）
- 包含：结果聚合与报告生成

## 输入接口
- 配置 `cfg`
- A/M 系列算法作为被测件

## 输出接口
- 仿真数据、定位结果、统计报告
- 为 H4 提供测试激励（数据格式对齐）

## 验收标准
- [ ] 6 种典型场景全部可跑
- [ ] Monte Carlo N=1000 并行
- [ ] 误差预算各项可独立注入验证
- [ ] 输出 CSV + 图表 + Markdown 报告

## 依赖模块
- 上游：A 系列、M 系列（作为被测）
- 下游：Monte Carlo 报告（M2 里程碑）

## 里程碑映射
- M1：全链路仿真
- M2：Monte Carlo N=1000

## 当前状态
- 部分实现：`run_doa_comparison.m`、`run_error_budget.m`、`run_full_simulation.m`
- 🔴 待开发：Monte Carlo 框架、多径、场景库完整化

## 相关文献与页面
- [[lr-usbl-development-plan]]

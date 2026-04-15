---
type: spec
module: A5-multi-buoy-fusion
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, algorithm, multi-buoy, GDOP]
---

# A5: 多潜标融合与 GDOP

> 模块线：A（算法）
> 依赖：[[huangjian-2019-lbl-usbl]]、[[guoyu-2024-lie-group-nav]]
> 里程碑映射：M2

## 目标
多潜标联合解算定位、GDOP 分析、野值剔除。

## 范围
- 包含：多潜标最小二乘/加权 LS、GDOP 计算与几何构型分析
- 包含：Grubbs + η 准则野值剔除、鲁棒最小二乘
- 包含：深度约束降维（有压力深度时）
- 不包含：EKF 跟踪（A6）

## 输入接口
- 各潜标 `(P_buoy_i, r_i, theta_i, phi_i, SNR_i)`
- 深度传感器数据（可选）

## 输出接口
- 融合定位 `P_self`
- GDOP 指标
- 参与解算的潜标子集 + 被剔除的野值

## 验收标准
- [ ] 典型几何（3+ 潜标）：精度优于单潜标
- [ ] Grubbs 剔除率与漏检率可配置
- [ ] GDOP 图可视化
- [ ] 鲁棒 LS 对 20% 野值污染仍收敛

## 依赖模块
- 上游：A4（单潜标解）
- 下游：A6（滤波输入）

## 里程碑映射
- M2：典型条件 < 1%R (N=1000)

## 当前状态
- 🔴 待开发：整个模块尚未实现

## 相关文献与页面
- [[huangjian-2019-lbl-usbl]]、[[guoyu-2024-lie-group-nav]]

---
type: spec
module: A2-doa-estimation
created: 2026-04-15
updated: 2026-04-15
status: in-progress
owner: TBD
tags: [spec, algorithm, doa]
---

# A2: DOA 估计套件

> 模块线：A（算法）
> 依赖：[[dingjie-2020-compact-usbl]]、[[zhengcuie-usbl-docking]]、[[quzhenzhao-2024-usbl-precision]]
> 里程碑映射：M1、M2

## 目标
提供多种 DOA 算法：ML 主力 + 辅助（相位比较/CBF/MUSIC/MVDR/UCA 模态）+ CRB，支持 d/λ=1.33 解模糊。

## 范围
- 包含：ML 两级搜索、相位比较（xy 最小二乘+球约束）、CBF、MVDR、MUSIC、UCA 模态 MUSIC、CRB
- 包含：ML 多脉冲积累、自适应网格细化
- 包含：基线分解 DOA（丁杰方法适配五元圆阵）
- 不包含：在线阵型校正（M4）、安装校准（M3）

## 输入接口
- 接收信号 `z[Nch × Nsample]`
- 阵列结构 `array`（来自 H2 标定表或 core/create_uca5）
- 频率/网格参数 `cfg.doa`
- 校正表（来自 M2）

## 输出接口
- DOA 估计 `(theta, phi)` + 置信度
- 谱图 `P_spectrum`（用于可视化与交叉验证）
- 算法一致性残差（主力 vs 辅助）

## 验收标准
- [ ] ML：@SNR=10dB 精度 ≤ 0.3° RMS
- [ ] 相位比较：与 ML 交叉验证残差 < 1°
- [ ] 所有算法 d/λ=1.33 不产生歧义峰（或歧义峰能被识别）
- [ ] 统一接口 `[theta, phi, P] = doa_xxx(z, array, cfg, grid)`

## 依赖模块
- 上游：A1（信号预处理）、M2（幅相校正）、H2（阵列几何）
- 下游：A4（坐标解算）

## 里程碑映射
- M1：理想条件 ML DOA < 0.3° RMS
- M2：典型条件 Monte Carlo 验证

## 当前状态
- 已实现：CBF、MVDR、MUSIC、ML、相位比较、UCA 模态、CRB
- 待开发：基线分解法、ML 多脉冲积累、自适应网格

## 相关文献与页面
- [[dingjie-2020-compact-usbl]]、[[zhengcuie-usbl-docking]]、[[quzhenzhao-2024-usbl-precision]]

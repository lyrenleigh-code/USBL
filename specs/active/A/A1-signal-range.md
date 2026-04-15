---
type: spec
module: A1-signal-range
created: 2026-04-15
updated: 2026-04-15
status: in-progress
owner: TBD
tags: [spec, algorithm, signal]
---

# A1: 信号与测距链路

> 模块线：A（算法）
> 依赖：[[usbl-positioning]]、[[yumin-2006-lr-usbl]]、[[huangjian-2019-lbl-usbl]]
> 里程碑映射：M1

## 目标
实现从 LFM 发射波形生成、匹配滤波、到精细时延估计（斜距）的完整链路。

## 范围
- 包含：LFM 生成、匹配滤波、互相关三点插值、改进 GCC（PHAT+功率谱加权）、匹配滤波加窗（Hamming/Kaiser）
- 不包含：声速修正（A3）、DOA（A2）、多径建模（S1）

## 输入接口
- 发射参数：`cfg.signal`（f0, BW, T, fs）
- 接收信号：`z[Nch × Nsample]`（来自 H4 采集或 S1 仿真）
- 声速：`c_eff`（来自 A3）

## 输出接口
- 斜距 `r`、斜距方差 `sigma_r`
- 时延估计质量因子（用于野值剔除）

## 验收标准
- [ ] 匹配滤波：CRB @SNR=0dB 相对测距误差 ≤ 0.1%R
- [ ] 三点插值：残差 ≤ 1/4 采样间隔
- [ ] 改进 GCC：相比 classic GCC 在低 SNR 下精度提升 ≥ 30%
- [ ] 全参数可配置（窗函数/加权方式）

## 依赖模块
- 上游：A3（声速）、S1/H4（信号源）
- 下游：A4（坐标解算）、A5（多潜标）

## 里程碑映射
- M1：理想条件 < 0.5%R 测距

## 当前状态
- 已实现：`gen_lfm.m`、`matched_filter_lfm.m`、三点插值
- 待开发：改进 GCC、匹配滤波加窗、多脉冲积累

## 相关文献与页面
- [[yumin-2006-lr-usbl]]、[[huangjian-2019-lbl-usbl]]

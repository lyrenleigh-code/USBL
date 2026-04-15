---
type: spec
module: H4-acquisition
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, hardware, electronics, FPGA]
---

# H4: 多通道采集电子

> 模块线：H（硬件）
> 依赖：[[usbl-hardware-spec]]
> 里程碑映射：HM2、HM4

## 目标
5 通道同步采集、前放/PGA/ADC/FPGA 一体化，通道间时延 < 10 ns。

## 范围
- 包含：低噪前放、PGA、Σ-Δ ADC、FPGA 时钟分发与聚合、千兆以太网上行
- 包含：10–15 kHz 带通抗混叠滤波
- 包含：GPS/PPS 授时输入
- 不包含：干端软件（H6）

## 输入接口
- 5ch 模拟信号（来自 H2 阵列）
- 外部时钟 / PPS（可选）

## 输出接口
- 数字流（带时间戳）→ 干端（H6）
- 通道同步性实测报告

## 验收标准
- [ ] 采样率 ≥ 100 kSPS/ch，16 bit+
- [ ] 通道间时延 < 10 ns
- [ ] 前端噪声 ≤ 1 nV/√Hz @10 kHz
- [ ] PGA 范围 0–60 dB
- [ ] OCXO + PPS 对时，时间戳精度 < 1 μs

## 依赖模块
- 上游：H2（信号源）
- 下游：H6（干端联调）、S1（仿真数据格式对齐）

## 里程碑映射
- HM2：原型板验证（Phase 2 末）
- HM4：整机联调（Phase 4 末）

## 当前状态
- 🔴 待开发：ADC/前放/FPGA 选型

## 相关文献与页面
- [[usbl-hardware-spec]]

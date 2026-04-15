---
type: spec
module: H3-transponder
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, hardware, transponder]
---

# H3: 应答器

> 模块线：H（硬件）
> 依赖：[[yumin-2006-lr-usbl]]、[[zhengcuie-usbl-docking]]、[[usbl-hardware-spec]]
> 里程碑映射：HM3

## 目标
潜标端应答器：LFM 发射、SL ≥ 185 dB、续航 ≥ 30 天、耐压 40 MPa。

## 范围
- 包含：发射换能器（大功率）、E 类功放、数字板（MCU+DDS）、电池仓、授时
- 包含：单目标应答 + CDMA/chirp 斜率编码预留
- 不包含：潜标系留结构

## 输入接口
- 信号波形定义（来自 A1）
- 链路预算 SL ≥ 185 dB
- 授时协议（来自 H6/S2）

## 输出接口
- 应答器样机 + 备份
- 发射特性测试报告
- 唯一 ID 方案（供 A5 多潜标区分）

## 验收标准
- [ ] SL ≥ 185 dB re 1μPa@1m（水池验证）
- [ ] 续航 ≥ 30 天 @1 Hz 应答
- [ ] 耐压 40 MPa
- [ ] 授时漂移：1 ppm/月，GPS 对时后 < 1 ms
- [ ] 支持外触发与定时自发两种模式

## 依赖模块
- 上游：A1、H5
- 下游：S2（试验部署）

## 里程碑映射
- HM3：样机交付（Phase 3 末）

## 当前状态
- 🔴 待开发

## 相关文献与页面
- [[yumin-2006-lr-usbl]]、[[zhengcuie-usbl-docking]]、[[usbl-hardware-spec]]

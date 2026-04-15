---
type: spec
module: M2-electroacoustic-consistency
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, measurement, calibration, electroacoustic]
---

# M2: 电声一致性标定

> 模块线：M（测量与校准）
> 依赖：[[usbl-hardware-spec]]、[[dingjie-2020-compact-usbl]]
> 里程碑映射：HM3、HM4

## 目标
测量各阵元+通道的幅度/相位响应，生成校正表，使等效一致性达到 DOA 要求。

## 范围
- 包含：逐元发射响应测试、阵列接收一致性测试、通道级电子增益/相位测试
- 包含：频段内（10±2 kHz）幅相校正表生成
- 包含：温度稳定性测试
- 不包含：阵型几何（M1）、年度复校触发逻辑（M5）

## 输入接口
- H2 阵列整机
- H4 采集电子
- 标定信号源（宽带扫频）

## 输出接口
- 幅相校正表 `array_cal.phase_amp[5][freq]`
- 校正后一致性测试报告
- 温度漂移曲线

## 验收标准
- [ ] 校正前幅度一致性 ≤ 1 dB，相位 ≤ 5°
- [ ] 校正后幅度残差 ≤ 0.3 dB，相位残差 ≤ 1°
- [ ] DOA 算法使用校正表后 @SNR=10dB 精度 ≤ 0.3° RMS（与 A2 验收对齐）
- [ ] 温度 −5~+40°C 漂移 ≤ 2° 相位

## 依赖模块
- 上游：H2、H4、M1（几何已知）
- 下游：A2（DOA）、H6（写入干端）、M4（在线重构参考）

## 里程碑映射
- HM3：初次标定
- HM4：整机联调前重新标定

## 当前状态
- 🔴 待开发

## 相关文献与页面
- [[usbl-hardware-spec]]、[[dingjie-2020-compact-usbl]]

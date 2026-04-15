---
type: spec
module: M1-array-geometry
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, measurement, calibration, array]
---

# M1: 阵型几何标定

> 模块线：M（测量与校准）
> 依赖：[[yumin-2006-lr-usbl]]、[[usbl-hardware-spec]]
> 里程碑映射：HM3、M1

## 目标
水池测量五元阵实际阵元坐标，输出几何校正表，精度 ≤ 0.5 mm。

## 范围
- 包含：水池几何标定 SOP、基准源布放、多位置测量反演阵元坐标
- 包含：几何校正表（阵元实际 xyz）
- 不包含：幅相一致性（M2）、安装偏差（M3）、在线重构（M4）

## 输入接口
- H2 阵列整机
- 水池基准源（已知位置）
- 标定工装与 SOP

## 输出接口
- 阵元实际坐标表 `array_cal.geom.xyz[5]`（写入干端）
- 标定精度报告
- 标定证书

## 验收标准
- [ ] 阵元坐标不确定度 ≤ 0.5 mm（3σ）
- [ ] 与机加工标称值偏差可追溯
- [ ] 标定重复性：三次独立标定结果一致性 < 0.3 mm

## 依赖模块
- 上游：H2（阵列）、H5（工装）
- 下游：A2（DOA 使用实际几何）、A4（坐标解算）、M4（在线重构参考）

## 里程碑映射
- HM3：随阵列整机交付标定证书

## 当前状态
- 🔴 待开发：SOP、工装、标定实验室选择

## 相关文献与页面
- [[yumin-2006-lr-usbl]]、[[usbl-hardware-spec]]、[[dingjie-2020-compact-usbl]]

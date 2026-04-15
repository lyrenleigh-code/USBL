---
type: spec
module: A3-ray-tracing
created: 2026-04-15
updated: 2026-04-15
status: in-progress
owner: TBD
tags: [spec, algorithm, sound-speed]
---

# A3: 声速与声线跟踪

> 模块线：A（算法）
> 依赖：[[yangbaoguo-2013-usbl-calibration]]、[[huangjian-2019-lbl-usbl]]
> 里程碑映射：M1、M2

## 目标
提供声速剖面处理与声线跟踪，支持 10 km 斜距的声速修正误差 ≤ 0.5 m/s。

## 范围
- 包含：SVP 读取/平滑/拓延、温盐压声速公式、常梯度分层、自适应分层声线跟踪
- 包含：等效声速（BELLHOP/迭代）、极端剖面迭代保护
- 不包含：多径建模（S1）

## 输入接口
- SVP 表 `[depth, c]` 或 CTD 原始数据
- 声源/接收深度、水平距离
- 迭代参数 `cfg.ray`

## 输出接口
- 真实传播路径（分段）
- 传播时间、等效声速 `c_eff`
- 声线弯曲引入的 DOA/距离修正量
- 收敛状态标志

## 验收标准
- [ ] 常规剖面（Munk）：相对误差 < 0.1%
- [ ] 极端剖面（跃层/负梯度）：迭代收敛，不发散
- [ ] 10 km 斜距修正残差 ≤ 3 m
- [ ] BELLHOP 冗余反演验证

## 依赖模块
- 上游：实测 SVP（S2 试验数据 或 S1 仿真）
- 下游：A1（测距修正）、A4（坐标修正）

## 里程碑映射
- M1：常规条件全链路满足
- M2：Monte Carlo 覆盖多种剖面

## 当前状态
- 已实现：`ray_trace.m`（常规剖面 OK）
- 🔴 已知问题：极端剖面不收敛
- 待开发：SVP 读取模块、BELLHOP 接口、迭代保护

## 相关文献与页面
- [[yangbaoguo-2013-usbl-calibration]]、[[huangjian-2019-lbl-usbl]]

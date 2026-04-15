---
type: spec
module: M4-online-baseline-reconstruction
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, measurement, calibration, online]
---

# M4: 在线基线重构

> 模块线：M（测量与校准）
> 依赖：[[dingjie-2020-compact-usbl]]、[[huangjian-2019-lbl-usbl]]
> 里程碑映射：M4

## 目标
运行期用观测数据在线反演阵型/幅相漂移，必要时触发重标定。

## 范围
- 包含：基线重构算法（有效声速+阵型联合估计，丁杰方法）
- 包含：漂移监测与告警
- 包含：EKF 状态扩展可选路径
- 不包含：离线水池标定（M1/M2）

## 输入接口
- 多站观测数据（运行期）
- 出厂校正表（来自 M1/M2）

## 输出接口
- 阵型/幅相在线估计值
- 漂移告警（超阈值触发 M5 重标定）

## 验收标准
- [ ] 仿真注入 1 mm 阵型误差 → 反演误差 < 0.3 mm
- [ ] 漂移告警灵敏度可配置
- [ ] 收敛速度：N=100 观测内收敛

## 依赖模块
- 上游：M1、M2、A5（多站观测）
- 下游：A2（动态更新阵列参数）、M5（触发复校）

## 里程碑映射
- M4：湖试中验证漂移监测

## 当前状态
- 🔴 待开发

## 相关文献与页面
- [[dingjie-2020-compact-usbl]]、[[huangjian-2019-lbl-usbl]]

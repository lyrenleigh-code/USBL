---
type: spec
module: M3-install-calibration
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, measurement, calibration, install]
---

# M3: 安装偏差校准

> 模块线：M（测量与校准）
> 依赖：[[yangbaoguo-2013-usbl-calibration]]、[[dingjie-2020-compact-usbl]]
> 里程碑映射：M3

## 目标
解决阵列相对载体的安装角偏差，海上两步校准 + M 估计抗差，精度 < 0.1°。

## 范围
- 包含：离线走圆校准（两步法）、矩阵分解解耦、M 估计鲁棒处理
- 包含：校准航迹设计（对称、多距离）
- 包含：校准工装（临时 GPS 应答器参考等）
- 不包含：在线自校准（M4）、阵型几何（M1）

## 输入接口
- 多次通过高精度真值点的观测数据
- 载体姿态记录
- GPS 真值

## 输出接口
- 阵列安装角偏差 `(dRoll, dPitch, dYaw)`
- 写入干端的校正参数
- 校准报告

## 验收标准
- [ ] 仿真：注入已知偏差 → 校准后残差 < 0.1°
- [ ] 湖试：重复校准重复性 < 0.15°
- [ ] 20% 野值污染下 M 估计仍收敛

## 依赖模块
- 上游：A4（坐标解算）、S2（试验平台提供真值）
- 下游：A4（写入安装参数）、A6（EKF 状态扩展可选）

## 里程碑映射
- M3：校准仿真报告（Phase 3 末）
- M4：湖试校准流程固化

## 当前状态
- 🔴 待开发（原 A6 安装校准迁移至此）

## 相关文献与页面
- [[yangbaoguo-2013-usbl-calibration]]、[[dingjie-2020-compact-usbl]]

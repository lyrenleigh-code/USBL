---
type: spec
module: A4-coord-iusbl
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, algorithm, coordinate, iUSBL]
---

# A4: 坐标变换与 iUSBL 解算

> 模块线：A（算法）
> 依赖：[[zhengcuie-usbl-docking]]（最相关的正向参考）
> 里程碑映射：M1
> **⚠ 本模块是文献空白区，需独立推导**

## 目标
推导并实现 iUSBL 逆向自定位的完整坐标变换链（阵系→载体→地理→潜标参考系），支持单潜标与多潜标解算。

## 范围
- 包含：阵系/载体/地理系定义与齐次变换矩阵
- 包含：逆向 iUSBL 单潜标解算（已知潜标位置 + 本地 DOA + 斜距 → 自身位置）
- 包含：平面阵 xy 最小二乘 + 球约束恢复 u_z
- 包含：误差雅可比推导（姿态误差/潜标位置误差/DOA 误差如何传播到定位误差）
- 不包含：多潜标融合（A5）、EKF（A6）

## 输入接口
- DOA `(theta, phi)`（来自 A2）
- 斜距 `r`（来自 A1）
- 姿态 `(roll, pitch, yaw)`（来自 IMU）
- 潜标位置 `P_buoy`（已知，地理系）
- 阵列安装参数（来自 M3）

## 输出接口
- 自身位置 `P_self`（地理系）
- 协方差 `Cov(P_self)`
- 变换链中间量（供调试与 EKF 观测方程）

## 验收标准
- [ ] 单潜标解算：理想条件 0 误差
- [ ] 误差雅可比：解析解与数值微分一致性 < 1e-6
- [ ] xy 最小二乘 + 球约束：恒满足 `|u| = 1`
- [ ] 提供完整的推导文档（wiki/concepts/iusbl-coordinate-derivation.md）

## 依赖模块
- 上游：A1、A2、M3（安装校准）
- 下游：A5（多潜标）、A6（EKF 观测方程）

## 里程碑映射
- M1：全链路仿真 iUSBL 理想条件 < 0.5%R

## 当前状态
- 已实现：`coordinate_transform.m`、`euler2rotmat.m`（正向方向）
- 🔴 待开发：**逆向 iUSBL 变换链（核心空白）**、误差雅可比、推导文档

## 相关文献与页面
- [[zhengcuie-usbl-docking]]

---
type: spec
module: A6-nav-ekf
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, algorithm, navigation, EKF]
---

# A6: 组合导航 EKF/UKF

> 模块线：A（算法）
> 依赖：[[huangjian-2019-lbl-usbl]]、[[hexutao-usbl-quad-array]]、[[guoyu-2024-lie-group-nav]]
> 里程碑映射：M4、M5、M6

## 目标
SINS/DVL/USBL/深度 多传感器融合的组合导航滤波器，含失效处理。

## 范围
- 包含：EKF/UKF 滤波器、R-T-S 平滑、状态扩展（在线校准）
- 包含：松组合（位置级）+ 紧组合（观测级）
- 包含：USBL 失效预测与信息重构（郭瑜思路）
- 包含：李群 IEKF 实现（可选，先做 EKF）
- 不包含：SINS 解算本体（假设 SINS 已提供）

## 输入接口
- SINS 位置/速度/姿态
- DVL 速度、压力深度
- USBL 定位（来自 A5）
- 可选：GPS（水面时）

## 输出接口
- 融合后位置/速度/姿态
- 协方差矩阵
- 健康状态（传感器可用性）

## 验收标准
- [ ] 静态：融合精度 ≤ 单 USBL 精度
- [ ] 动态 1 m/s：轨迹连续、无跳变
- [ ] USBL 失效 60 s 内惯性递推误差可控
- [ ] R-T-S 平滑后精度再提升 ≥ 20%

## 依赖模块
- 上游：A5（USBL 定位）、外部 SINS/DVL
- 下游：S2（试验平台）

## 里程碑映射
- M4-M6：湖/海试长期跟踪

## 当前状态
- 🔴 待开发：整个模块尚未实现

## 相关文献与页面
- [[huangjian-2019-lbl-usbl]]、[[hexutao-usbl-quad-array]]、[[guoyu-2024-lie-group-nav]]

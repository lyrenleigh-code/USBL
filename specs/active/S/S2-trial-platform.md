---
type: spec
module: S2-trial-platform
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, system, trial, field-test]
---

# S2: 试验平台

> 模块线：S（系统）
> 依赖：H6、M 系列
> 里程碑映射：M4、M5、M6、HM5

## 目标
湖试/浅海/深海三级现场试验的方案、保障、数据管理。

## 范围
- 包含：试验方案（布放/航迹/潜标阵布设/真值获取）
- 包含：数据采集与回放系统
- 包含：现场标定流程（基于 M1–M3 SOP）
- 包含：实采数据回放处理（离线验证算法）
- 不包含：算法本体（A 系列）

## 输入接口
- H6 整机
- 外部：船只、高精度 GPS、CTD、深度计
- M1–M3 SOP

## 输出接口
- 试验原始数据集
- 精度评估报告
- 校准流程固化文档

## 验收标准
- [ ] 湖试（M4）：2 km 内 < 1%R
- [ ] 浅海（M5）：5 km 内 < 1%R
- [ ] 深海（M6）：10 km 内 < 1%R
- [ ] 每次试验可追溯的数据集

## 依赖模块
- 上游：H6、M1–M3、A 全系列
- 下游：最终验收报告

## 里程碑映射
- M4-M6：三级试验

## 当前状态
- 🔴 待开发（Phase 5）

## 相关文献与页面
- [[lr-usbl-development-plan]]、[[usbl-hardware-spec]]

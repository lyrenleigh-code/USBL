---
type: spec
module: M5-periodic-recal-sop
created: 2026-04-15
updated: 2026-04-15
status: draft
owner: TBD
tags: [spec, measurement, calibration, sop, maintenance]
---

# M5: 年度复校 SOP

> 模块线：M（测量与校准）
> 依赖：[[yangbaoguo-2013-usbl-calibration]]、[[usbl-hardware-spec]]
> 里程碑映射：M6 之后持续

## 目标
服役后的定期复校标准作业程序：阵型、电声、安装三层一致性复核。

## 范围
- 包含：年度/季度/触发式复校流程定义
- 包含：复校工装清单
- 包含：校正表更新与版本管理
- 不包含：初次标定（M1/M2/M3）

## 输入接口
- 服役期运行数据（M4 告警 或 定期触发）
- 历次标定记录

## 输出接口
- SOP 文档
- 校正表版本库
- 维护保养手册

## 验收标准
- [ ] SOP 完整覆盖三层（阵型/电声/安装）
- [ ] 每次复校输出可追溯报告
- [ ] 校正表版本化管理（含回滚机制）
- [ ] 用户可独立执行

## 依赖模块
- 上游：M1、M2、M3、M4
- 下游：运维（非开发模块）

## 里程碑映射
- M6 后持续维护

## 当前状态
- 🔴 待开发（低优先级，Phase 5 末）

## 相关文献与页面
- [[yangbaoguo-2013-usbl-calibration]]、[[usbl-hardware-spec]]

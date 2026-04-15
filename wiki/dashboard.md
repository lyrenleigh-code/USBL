---
type: topic
created: 2026-04-13
updated: 2026-04-15
tags: [仪表盘, 聚合视图]
---

# 项目仪表盘

> 本页只做**聚合引用**，不存状态数据。状态源：根目录 `TODO.md` + 各模块 spec 卡。
>
> 相关：[[usbl-moc]] · [[lr-usbl-development-plan]] · [[usbl-literature-review]] · [[usbl-hardware-spec]]

---

## 系统参数（静态）

| 参数 | 值 | 对标 |
|------|-----|------|
| 中心频率 | 10 kHz (λ=15 cm) | HiPAP 102 |
| 阵列 | 五元 UCA, d=20 cm, d/λ=1.33 | 自研 |
| 最大距离 | ≥ 10 km | Posidonia |
| 定位精度 | < 1%R | Posidonia (0.2%R) |
| 信号体制 | LFM, BW=4 kHz, T=100 ms | — |
| 定位模式 | 逆向 USBL (iUSBL) | — |

---

## 当前焦点

> 详见 `TODO.md` 的「当前焦点」章节。本节仅做引用。

**Phase 1 + Phase 1H 并行推进**

- P0 算法阻塞：**A4** iUSBL 坐标变换（文献空白）、**A3** ray_trace 收敛、**S1** Monte Carlo 框架
- P0 硬件阻塞：**H1** 换能器参数冻结、**H3** 应答器方案、**H4** 采集电子选型
- P1 推进项：**A1** 改进 GCC、**A2** 基线分解法、**H2** 阵型公差分析

---

## 阻塞与已知问题

> 详见各 spec 卡「当前状态」字段。

| 问题 | 归属模块 | Spec |
|------|---------|------|
| iUSBL 逆向变换（文献空白） | A4 | `specs/active/A/A4-coord-iusbl.md` |
| `ray_trace.m` 极端剖面不收敛 | A3 | `specs/active/A/A3-ray-tracing.md` |
| 10 kHz 宽带换能器设计 | H1 | `specs/active/H/H1-transducer.md` |
| 阵元幅相一致性 | M2/H1 | `specs/active/M/M2-electroacoustic-consistency.md` |

---

## 最近变更

> 详见 `wiki/log.md`。节选：

- **2026-04-15**：项目模块化重构（方案 B），19 个模块 spec 卡落地；specs/active/ 分 A/H/M/S 子目录；simulation 各子目录加 README
- **2026-04-14**：研制计划扩充为五阶段+硬件并行线+11 重难点；新建硬件自研专题页
- **2026-04-13**：9 篇论文摘要 + 文献综述 + 研制计划初稿 + 知识地图

---

## 导航入口

- **模块索引（状态源）**：`../../TODO.md`
- **研制路线图（战略）**：[[lr-usbl-development-plan]]
- **文献综述**：[[usbl-literature-review]]
- **硬件专题**：[[usbl-hardware-spec]]
- **知识地图**：[[usbl-moc]]
- **概念页**：[[usbl-positioning]]

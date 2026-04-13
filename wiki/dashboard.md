---
type: topic
created: 2026-04-13
updated: 2026-04-13
tags: [仪表盘, 项目管理]
---

# 项目仪表盘

> 更新日期：2026-04-13
> 导航：[[usbl-moc]] | 研制计划：[[lr-usbl-development-plan]] | 文献综述：[[usbl-literature-review]]

---

## 系统参数

| 参数 | 值 | 对标 |
|------|-----|------|
| 中心频率 | 10 kHz (λ=15cm) | HiPAP 102 (10-15kHz) |
| 阵列 | 五元均匀圆阵 UCA, d=20cm, d/λ=1.33 | 自研 |
| 最大距离 | ≥ 10 km | Posidonia (10km) |
| 定位精度 | < 1%R | Posidonia (0.2%R) |
| 信号体制 | LFM, BW=4kHz, T=100ms | — |
| 定位模式 | 逆向USBL自定位 (iUSBL) | — |

---

## 仿真模块状态

| 目录 | 模块 | 函数数 | 状态 |
|------|------|--------|------|
| `config/` | 全局参数 | 1 | ✅ usbl_config.m |
| `core/` | 阵列模型 | 2 | ✅ create_uca5, steering_vector |
| `core/` | 信号生成 | 1 | ✅ gen_lfm |
| `core/` | 匹配滤波 | 1 | ✅ matched_filter_lfm |
| `core/` | 信道仿真 | 1 | ✅ simulate_channel |
| `core/` | 射线追踪 | 1 | 🔶 ray_trace（极端剖面不收敛） |
| `core/` | 坐标变换 | 2 | 🔶 euler2rotmat, coordinate_transform（缺 iUSBL 链路） |
| `doa/` | CBF | 1 | ✅ doa_cbf |
| `doa/` | MVDR | 1 | ✅ doa_mvdr |
| `doa/` | MUSIC | 1 | ✅ doa_music |
| `doa/` | **ML两级搜索** | 1 | ✅ doa_ml（主力） |
| `doa/` | 相位比较 | 1 | ✅ doa_phase_compare（辅助） |
| `doa/` | UCA模态MUSIC | 1 | ✅ doa_uca_mode_music |
| `doa/` | CRB | 1 | ✅ compute_doa_crb |
| `analysis/` | 误差分配 | 1 | ✅ error_budget_analysis |
| `analysis/` | 灵敏度 | 1 | ✅ sensitivity_analysis |
| — | DOA对比主脚本 | 1 | ✅ run_doa_comparison |
| — | 误差分配主脚本 | 1 | ✅ run_error_budget |
| — | 全链路仿真 | 1 | 🔶 run_full_simulation（缺声线跟踪+坐标变换） |

**合计：20 个 MATLAB 文件**

---

## 研制阶段进度

| 阶段 | 内容 | 状态 |
|------|------|------|
| **Phase 0** | 理论验证（DOA算法对比、CRB、误差分析） | ✅ 已完成 |
| **Phase 1** | 算法原型完善 | 🔶 **当前阶段** |
| Phase 2 | 系统仿真验证（Monte Carlo） | 🔴 未开始 |
| Phase 3 | 校准技术开发 | 🔴 未开始 |
| Phase 4 | 系统集成试验（湖试→海试） | 🔴 未开始 |

---

## Phase 1 当前待办

| 优先级 | 任务 | 依据 | 状态 |
|--------|------|------|------|
| **P0** | 声线跟踪完善（自适应分层） | [[yangbaoguo-2013-usbl-calibration]] | 🔴 待做 |
| **P0** | 声速剖面处理模块 | [[yangbaoguo-2013-usbl-calibration]] | 🔴 待做 |
| **P0** | iUSBL坐标变换推导与实现 | 项目核心需求 | 🔴 待做 |
| P1 | 改进GCC时延估计 | [[huangjian-2019-lbl-usbl]] | 🔴 待做 |
| P1 | 基线分解DOA算法 | [[dingjie-2020-compact-usbl]] | 🔴 待做 |
| P1 | 全链路仿真集成 | — | 🔴 待做 |
| P2 | 安装校准算法框架 | [[yangbaoguo-2013-usbl-calibration]] | 🔴 待做 |
| P2 | Monte Carlo评估框架 | — | 🔴 待做 |
| P3 | 多径仿真模块 | — | 🔴 待做 |
| P3 | 深度辅助定位 | — | 🔴 待做 |

---

## 里程碑

| 节点 | 交付 | 验收标准 | 状态 |
|------|------|---------|------|
| M1 | MATLAB全链路仿真 | 理想条件 < 0.5%R | 🔴 |
| M2 | Monte Carlo报告 | 典型条件 < 1%R (N=1000) | 🔴 |
| M3 | 校准仿真报告 | 安装角精度 < 0.1° | 🔴 |
| M4 | 湖试报告 | 2km内 < 1%R | 🔴 |
| M5 | 浅海报告 | 5km内 < 1%R | 🔴 |
| M6 | 验收报告 | 10km内 < 1%R | 🔴 |

---

## 已知问题

| 问题 | 状态 | 说明 |
|------|------|------|
| ray_trace.m 极端剖面不收敛 | 🔶待修复 | 需加迭代保护 |
| 仿真未考虑多径效应 | 🔴待做 | 需加海面/海底反射模型 |
| caxis 已改为 clim | ✅已修复 | 新版MATLAB兼容 |

---

## 知识库

- 文献综述：[[usbl-literature-review]]（9篇论文，六层研究体系）
- 研制计划：[[lr-usbl-development-plan]]（四阶段路线图）
- 概念页：[[usbl-positioning]]（已 promote 到 Hub）
- 论文摘要：9篇 → `wiki/source-summaries/`

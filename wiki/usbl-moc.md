---
type: topic
created: 2026-04-13
updated: 2026-04-13
tags: [MOC, 知识地图]
---

# USBL 自定位系统 MOC

> 逆向USBL自定位：已知潜标位置 → 五元圆阵接收应答信号 → 测距+DOA → 反算自身位置
> 仪表盘：[[dashboard]] | 研制计划：[[lr-usbl-development-plan]]

---

## 信号链路

```
[潜标应答器] → 声信号传播(10kHz LFM) → [五元圆阵接收]
  → 匹配滤波(测距) → DOA估计(测向) → 声线跟踪(声速修正)
  → 坐标变换(iUSBL) → 自身地理位置输出
```

---

## 仿真代码地图

### config/ — 全局参数

| 文件 | 功能 |
|------|------|
| `usbl_config.m` | 所有参数集中配置（频率/阵列/信号/信道/算法） |

### core/ — 基础模块

| 文件 | 功能 | 依赖 |
|------|------|------|
| `create_uca5.m` | 五元均匀圆阵模型 | config |
| `steering_vector.m` | 导向向量计算 | config |
| `gen_lfm.m` | LFM信号生成 | config |
| `matched_filter_lfm.m` | 匹配滤波（脉压+TOA） | gen_lfm |
| `simulate_channel.m` | 信道仿真（多径+噪声） | config |
| `ray_trace.m` | 射线追踪（声速剖面→声线弯曲） | config |
| `euler2rotmat.m` | 欧拉角→旋转矩阵 | — |
| `coordinate_transform.m` | 坐标变换链（阵→船→地理） | euler2rotmat |

### doa/ — DOA估计算法

| 文件 | 算法 | 角色 | 参考文献 |
|------|------|------|---------|
| `doa_cbf.m` | 常规波束形成 | 粗估计/解模糊基底 | — |
| `doa_mvdr.m` | MVDR/Capon | 对比 | — |
| `doa_music.m` | MUSIC | 对比 | — |
| `doa_ml.m` | **ML两级搜索** | **主力** | — |
| `doa_phase_compare.m` | 相位比较法 | **辅助**（交叉验证） | — |
| `doa_uca_mode_music.m` | UCA模态MUSIC | 对比 | — |
| `compute_doa_crb.m` | CRB理论下界 | 性能评估 | — |

统一接口：`[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)`

### analysis/ — 分析工具

| 文件 | 功能 |
|------|------|
| `error_budget_analysis.m` | 各误差源贡献分离 |
| `sensitivity_analysis.m` | 参数灵敏度分析 |

### 主脚本

| 文件 | 功能 |
|------|------|
| `run_doa_comparison.m` | DOA算法对比（6种算法 × 多场景） |
| `run_error_budget.m` | 误差分配验证 |
| `run_full_simulation.m` | 全链路信号级仿真 |

---

## 待开发模块（Phase 1）

| 模块 | 功能 | 来源文献 | 位置 |
|------|------|---------|------|
| 声速剖面处理 | SVP读取/平滑/拓延/有效声速 | [[yangbaoguo-2013-usbl-calibration]] | `core/` |
| 自适应声线跟踪 | 自适应辛普森分层 | [[yangbaoguo-2013-usbl-calibration]] | `core/` |
| 改进GCC测距 | PHAT+功率谱加权 | [[huangjian-2019-lbl-usbl]] | `core/` |
| 基线分解DOA | 任意阵型最小二乘 | [[dingjie-2020-compact-usbl]] | `doa/` |
| iUSBL坐标变换 | 逆向自定位变换链 | 项目需求 | `core/` |
| 安装校准 | 两步法+M估计 | [[yangbaoguo-2013-usbl-calibration]] | 新目录 `calibration/` |
| 多径仿真 | 海面/海底反射 | — | `core/` |

---

## 知识层地图

### 概念

- [[usbl-positioning]] — USBL定位系统全局概念（已promote到Hub）

### 专题

- [[usbl-literature-review]] — 9篇文献综述
- [[lr-usbl-development-plan]] — 四阶段研制计划
- [[dashboard]] — 项目仪表盘

### 论文摘要（9篇）

| 方向 | 论文 |
|------|------|
| 系统研制 | [[yumin-2006-lr-usbl]] 喻敏 — 长程USBL全链路 |
| 基阵+校准 | [[dingjie-2020-compact-usbl]] 丁杰 — 基线分解+阵型校准 |
| 安装校准 | [[yangbaoguo-2013-usbl-calibration]] 杨保国 — 声线跟踪+M估计 |
| 对接应用 | [[zhengcuie-usbl-docking]] 郑翠娥 — 抗模糊+位姿解算 |
| 精度改进 | [[quzhenzhao-2024-usbl-precision]] 蘧振超 — 多阵型融合 |
| LBL/USBL | [[huangjian-2019-lbl-usbl]] 黄健 — 改进GCC+有效声速 |
| 被动定位 | [[liufeng-2024-passive-localization]] 刘峰 — TDOA+FIM |
| 基阵设计 | [[hexutao-usbl-quad-array]] 何旭涛 — 四元阵+EKF |
| 组合导航 | [[guoyu-2024-lie-group-nav]] 郭瑜 — 李群SINS/DVL/USBL |

---

## Hub 关联

- Hub 概念页：`Ohmybrain/wiki/concepts/usbl-positioning.md`
- Hub 阵列处理：`Ohmybrain/wiki/concepts/mimo-and-array-processing.md`
- Hub 信号处理：`Ohmybrain/wiki/concepts/signal-processing-fundamentals.md`

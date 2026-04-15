# USBL 自定位系统算法 — 模块索引

> 本文件是**模块索引总览**。细粒度任务请到各模块 spec（`specs/active/<MOD>.md`）查看。
>
> 模块划分方案：方案 B（2026-04-15 确立）—— A 算法 / H 硬件 / M 测量校准 / S 系统，共 19 个模块。

## 状态图例

- 🟢 已实现 / Done
- 🟡 部分实现 / In-Progress
- 🔴 未开始 / Draft
- ⛔ 阻塞 / Blocked

## 算法线（A 系列）

| 编号 | 模块 | 状态 | 里程碑 | Spec |
|------|------|------|-------|------|
| A1 | 信号与测距链路 | 🟡 | M1 | [A1](specs/active/A/A1-signal-range.md) |
| A2 | DOA 估计套件 | 🟡 | M1/M2 | [A2](specs/active/A/A2-doa-estimation.md) |
| A3 | 声速与声线跟踪 | 🟡 (极端剖面🔴) | M1/M2 | [A3](specs/active/A/A3-ray-tracing.md) |
| A4 | 坐标变换与 iUSBL 解算 | 🔴 **文献空白** | M1 | [A4](specs/active/A/A4-coord-iusbl.md) |
| A5 | 多潜标融合与 GDOP | 🔴 | M2 | [A5](specs/active/A/A5-multi-buoy-fusion.md) |
| A6 | 组合导航 EKF/UKF | 🔴 | M4–M6 | [A6](specs/active/A/A6-nav-ekf.md) |

## 硬件线（H 系列，自研并行）

| 编号 | 模块 | 状态 | 里程碑 | Spec |
|------|------|------|-------|------|
| H1 | 接收换能器 | 🔴 | HM1/HM2 | [H1](specs/active/H/H1-transducer.md) |
| H2 | 五元 UCA 阵列封装 | 🔴 | HM3 | [H2](specs/active/H/H2-array-package.md) |
| H3 | 应答器 | 🔴 | HM3 | [H3](specs/active/H/H3-transponder.md) |
| H4 | 多通道采集电子 | 🔴 | HM2/HM4 | [H4](specs/active/H/H4-acquisition.md) |
| H5 | 结构与水密 | 🔴 | HM3 | [H5](specs/active/H/H5-structure-sealing.md) |
| H6 | 系统联调与干端软件 | 🔴 | HM4 | [H6](specs/active/H/H6-integration.md) |

## 测量与校准线（M 系列，横切算法+硬件）

| 编号 | 模块 | 状态 | 里程碑 | Spec |
|------|------|------|-------|------|
| M1 | 阵型几何标定 | 🔴 | HM3/M1 | [M1](specs/active/M/M1-array-geometry.md) |
| M2 | 电声一致性标定 | 🔴 | HM3/HM4 | [M2](specs/active/M/M2-electroacoustic-consistency.md) |
| M3 | 安装偏差校准 | 🔴 | M3 | [M3](specs/active/M/M3-install-calibration.md) |
| M4 | 在线基线重构 | 🔴 | M4 | [M4](specs/active/M/M4-online-baseline-reconstruction.md) |
| M5 | 年度复校 SOP | 🔴 | M6+ | [M5](specs/active/M/M5-periodic-recal-sop.md) |

## 系统线（S 系列）

| 编号 | 模块 | 状态 | 里程碑 | Spec |
|------|------|------|-------|------|
| S1 | 仿真平台 | 🟡 | M1/M2 | [S1](specs/active/S/S1-simulation-platform.md) |
| S2 | 试验平台 | 🔴 | M4–M6 | [S2](specs/active/S/S2-trial-platform.md) |

---

## 里程碑映射速查

### 算法里程碑
- **M1** MATLAB 全链路仿真（<0.5%R）← A1+A2+A3+A4+S1
- **M2** Monte Carlo N=1000（<1%R）← A5+S1
- **M3** 校准仿真报告 ← M3
- **M4** 湖试（2km）← H6+M3+A6+S2
- **M5** 浅海（5km）← H6+A6+S2
- **M6** 深海（10km）← 全部

### 硬件里程碑
- **HM1** 电声参数冻结（Phase 1 末）← H1
- **HM2** 换能器样品+采集电子原型（Phase 2 末）← H1+H4
- **HM3** 阵列整机+应答器样机（Phase 3 末）← H2+H3+H5+M1+M2
- **HM4** 全系统联调通过（Phase 4 末）← H6+M2
- **HM5** 现场可用系统（Phase 5）← S2

---

## 当前焦点（Phase 1 + Phase 1H）

### P0 算法侧（阻塞 M1）
- **A4** iUSBL 逆向坐标变换（文献空白，核心阻塞项）
- **A3** 声线跟踪极端剖面迭代保护
- **S1** 全链路仿真集成 + Monte Carlo 框架

### P0 硬件侧（阻塞 HM1）
- **H1** 换能器方案对比 + 匹配层仿真 + 电声参数冻结
- **H3** 应答器链路预算反推与方案
- **H4** ADC/前放/FPGA 选型

### P1
- **A1** 改进 GCC + 匹配滤波加窗
- **A2** 基线分解法 + ML 多脉冲积累
- **H2** 阵型公差分析
- **H4** 采集电子详细设计

---

## 技术债务 / 改进项（跨模块）

- A3 `ray_trace.m` 极端剖面不收敛 → 见 [A3](specs/active/A/A3-ray-tracing.md)
- S1 `simulate_channel.m` 缺多径模型 → 见 [S1](specs/active/S/S1-simulation-platform.md)
- A2 DOA 算法多信源支持（CDMA 预留）→ 见 [A2](specs/active/A/A2-doa-estimation.md)
- S1 平台运动轨迹仿真 → 见 [S1](specs/active/S/S1-simulation-platform.md)

---

## 工作流

所有模块遵循 `workflows/engineering/`：
1. `01-spec.md` — 已用本索引对应的 spec 卡承载
2. `02-plan.md` — 每模块落地前先写 plan（放 `plans/<MOD>.md`）
3. `03-implement.md` — 产出代码+测试
4. `04-validate.md` — 验证+同步 wiki+归档+commit

归档：模块完成后将 spec 卡移至 `specs/archive/`。

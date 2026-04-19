---
type: concept
created: 2026-04-13
updated: 2026-04-13
tags: [USBL, 水声定位, DOA, 阵列处理]
promoted_to_hub: 2026-04-13
promoted_topics: ["usbl-positioning"]
---

# 超短基线定位系统 (USBL)

## 定义

超短基线 (Ultra-Short Baseline, USBL) 定位系统是一种水声定位技术，利用紧凑基阵（基线长度 < 0.5 m）上多个接收阵元之间的相位差或时延差测量目标方位角 (DOA)，结合声信号传播时延测量斜距，从而确定水下目标的三维位置。

## 核心技术链路

```
信号发射 → 信道传播 → 阵列接收 → 匹配滤波(测距) → DOA估计(测向) →
声线跟踪(声速修正) → 坐标变换(姿态+GPS) → 地理坐标输出
```

## 关键技术问题

- **DOA 估计**：从阵元间相位差/时延差估计目标方位角，受 SNR 和阵型限制
- **相位模糊**：当阵元间距 > λ/2 时出现相位模糊，需要解模糊算法
- **声速修正**：远距离声线弯曲导致定位偏差，需要声速剖面修正
- **安装校准**：传感器间安装偏差（旋转角+杆臂）直接影响定位精度
- **阵型误差**：换能器几何中心 ≠ 声辐射中心，需要修正

## 系统分类

| 类型 | 说明 | 代表 |
|------|------|------|
| 正向 USBL | 母船定位水下目标 | 大部分商用系统 |
| 逆向 USBL (iUSBL) | 水下平台自定位 | 本项目 |
| LBL/USBL 组合 | 长基线 + 超短基线融合 | [[huangjian-2019-lbl-usbl]] |
| GAPS 集成型 | USBL+GPS+INS 一体化 | iXblue GAPS |

## 商用设备关键参数

| 设备 | 厂商 | 距离 | 精度 | 频段 |
|------|------|------|------|------|
| HPT 7000L | Sonardyne | 12 km | 0.12%R | 14-19 kHz |
| HiPAP 102 | Kongsberg | 10 km | 0.24%R | 10-15 kHz |
| Posidonia | iXblue | 10 km | 0.2%R | 14-18 kHz |
| GAPS | iXblue | 4 km | 0.17%R | 21-30 kHz |
| iTrack | 中海达 | 3 km | 0.5m+1%D | 15-25 kHz |

（数据来自 [[dingjie-2020-compact-usbl]]）

## 与本项目的关联

本项目采用**逆向 USBL 自定位**模式：
- **笼式五元立体阵 CAGE5**（2026-04-19 从 UCA5 迁移；供应商 NeUB-816 产品）
  - 结构：4 外围立柱 + 1 中央 + 上下双盘支撑
  - 佐证来源：工程图 [[five-element-transducer-assembly-drawing-vA]] + 垂直指向性非对称 [[neub-816-test-report-260102]]
- **12 kHz** 中心频率（λ = 12.5 cm；2026-04-19 从 10 kHz 更新，依据供应商测试报告）
- 目标距离 ≥ 10 km，精度 < 1%R
- ML 两级搜索作为主力 DOA 算法（立体阵下无需修改，`steering_vector` 数学通用）
- 相位比较法走 3D LS 分支（立体阵专用，`doa_phase_compare.m` 2026-04-19 改造完成）

## 相关概念

- [[mimo-and-array-processing]] — 阵列信号处理基础（Hub）
- [[signal-processing-fundamentals]] — 估计理论/CRLB（Hub）
- [[acoustic-calibration]] — 校准技术
- [[sound-velocity-correction]] — 声速修正

## 来源

- [[yumin-2006-lr-usbl]] — 系统研制全链路参考
- [[dingjie-2020-compact-usbl]] — 基线分解算法 + 商用设备参数
- [[five-element-transducer-assembly-drawing-vA]] — 本项目阵列的机械工程图（江苏水声，2026-04-15）
- [[neub-816-test-report-260102]] — 本项目阵列的电声测试报告（江苏水声，2026-01-24）
- [[yangbaoguo-2013-usbl-calibration]] — 安装校准理论
- [[zhengcuie-usbl-docking]] — 对接应用 + 抗模糊
- [[quzhenzhao-2024-usbl-precision]] — 多阵型融合
- [[huangjian-2019-lbl-usbl]] — LBL/USBL 组合 + 时延估计
- [[hexutao-usbl-quad-array]] — 四元基阵 + EKF
- [[guoyu-2024-lie-group-nav]] — 李群组合导航
- [[liufeng-2024-passive-localization]] — 被动定位（TDOA体制）

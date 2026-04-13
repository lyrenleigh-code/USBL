# USBL 自定位系统算法项目

> **Hub**: `D:\Claude\Ohmybrain` — 跨项目知识中心（查询领域知识/回流结论用 `/promote-answer`）
> **模板**: `D:\Claude\ohmybrain-core` — 项目模板源

## 项目概述

基于超短基线(USBL)的水下自定位系统算法研发。系统利用已知位置潜标上的声学应答器，通过五元圆阵接收应答信号，测量斜距和DOA，反算自身平台位置。算法覆盖从信号检测到定位输出的全链路。

## 系统关键参数

- 中心频率: 10 kHz, 波长 λ = 15 cm
- 阵列: 五元均匀圆阵(UCA), 阵元间距 20 cm, d/λ = 1.33 (存在相位模糊)
- 最大作用距离: ≥ 10 km
- 定位精度: 优于斜距的 1%
- 定位模式: 逆向USBL自定位 (已知潜标位置, 求解自身位置)
- 信号体制: LFM, 带宽 4 kHz, 脉宽 100 ms
- 算法平台: PC (MATLAB原型 → C/C++产品化)

## 技术决策记录

- DOA主力算法: **ML两级搜索** (单快拍最优, 全局搜索天然解模糊)
- DOA辅助算法: **相位比较法** (交叉验证 + 残差质量指标)
- CBF作为解模糊粗估计基底
- 链路预算用**单程TL** (应答器模式, 应答器SL=185dB)
- 平面阵DOA解算: 只用xy分量做最小二乘, u_z由单位球约束恢复

## 目录结构

```
D:\TechReq\USBL\
├── CLAUDE.md                          # 本文件
├── TODO.md                            # 任务跟踪
├── USBL自定位系统算法初步技术方案.docx    # 技术方案文档
├── reference/                         # 参考文献 (4篇PDF)
└── simulation/                        # MATLAB仿真环境
    ├── config/usbl_config.m           # 全局参数配置 (改这里影响全局)
    ├── core/                          # 基础模块
    │   ├── create_uca5.m             # 五元圆阵模型
    │   ├── steering_vector.m         # 导向向量
    │   ├── gen_lfm.m                 # LFM信号生成
    │   ├── matched_filter_lfm.m      # 匹配滤波
    │   ├── simulate_channel.m        # 信道仿真
    │   ├── ray_trace.m               # 射线追踪
    │   ├── euler2rotmat.m            # 旋转矩阵
    │   └── coordinate_transform.m    # 坐标变换链
    ├── doa/                           # DOA估计算法
    │   ├── doa_cbf.m                 # 常规波束形成
    │   ├── doa_mvdr.m                # MVDR/Capon
    │   ├── doa_music.m               # MUSIC
    │   ├── doa_ml.m                  # 最大似然 (主力)
    │   ├── doa_phase_compare.m       # 相位比较 (辅助)
    │   ├── doa_uca_mode_music.m      # UCA模态MUSIC
    │   └── compute_doa_crb.m         # CRB计算
    ├── analysis/                      # 分析工具
    │   ├── error_budget_analysis.m   # 误差分配
    │   └── sensitivity_analysis.m    # 灵敏度分析
    ├── run_doa_comparison.m           # DOA算法对比主脚本
    ├── run_error_budget.m             # 误差分配主脚本
    └── run_full_simulation.m          # 全链路信号级仿真
```

## 代码规范

- 语言: MATLAB (仿真原型), 中文注释
- 所有参数集中在 `usbl_config.m`, 各模块通过 cfg 结构体引用
- DOA算法统一接口: `[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)`
- 角度约定: theta = 极角(0°=阵法线/下方), phi = 方位角(0°=前方/x轴)
- 坐标系: 阵面在xy平面, 法线沿z轴正方向(向下)
- 运行仿真前先 `addpath('config', 'core', 'doa', 'analysis')`

## 已知问题

- `run_doa_comparison.m` 中 `caxis` 已被用户改为 `clim` (新版MATLAB兼容)
- 射线追踪 `ray_trace.m` 在极端声速剖面下可能不收敛, 需要加迭代保护
- 当前仿真未考虑多径效应, 后续需加入海面/海底反射模型

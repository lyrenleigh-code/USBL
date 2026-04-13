# USBL 定位

> 超短基线（Ultra-Short Baseline）水下声学定位系统
> 项目：`D:\TechReq\USBL\`（五元圆阵逆向自定位系统）
> 参考文献：`USBL/reference/`（4篇中文学位论文）

#USBL #定位 #领域知识

---

## 一、水声定位系统对比

| 系统             | 基线长度      | 精度          | 部署复杂度      | 适用场景           |
| -------------- | --------- | ----------- | ---------- | -------------- |
| **LBL**（长基线）   | 数百米~数公里   | **最高**（cm级） | 高（海底布阵）    | 高精度测量、深海       |
| **SBL**（短基线）   | 数米~数十米    | 中（随间距提升）    | 中（船体安装）    | 大型船舶/平台        |
| **USBL**（超短基线） | ~λ/2（厘米级） | 斜距的0.06%-2% | **低**（单设备） | 灵活部署、ROV/AUV跟踪 |

USBL通过测量**斜距（TOA/TOF）**和**到达方向（DOA）**实现定位，精度与距离成正比。

> 参考：[Hydro International — Underwater Acoustic Positioning Systems](https://www.hydro-international.com/files/3fb82f3961d1f9890fc2a475cf56d9ed.pdf); [Wikipedia — USBL](https://en.wikipedia.org/wiki/Underwater_acoustic_positioning_system)

---

## 二、USBL核心算法

### 2.1 DOA估计

项目已实现6种算法（`simulation/doa/`），技术选型：**ML为主力，相位比较为辅助**。

| 算法 | 原理 | 优势 | 劣势 | 参考文献 |
|------|------|------|------|---------|
| **CBF** | 常规波束形成，导向向量扫描 | 简单鲁棒，解模糊粗估 | 分辨率受阵列孔径限制 | Van Trees [^1] |
| **MVDR/Capon** | 自适应加权最小方差无畸变响应 | 抑制干扰，分辨率优于CBF | 需多快拍，少阵元退化 | Capon (1969) [^2] |
| **MUSIC** | 信号/噪声子空间分解，谱峰搜索 | 超分辨 | 需多快拍+信源数估计 | Schmidt (1986) [^3] |
| **ESPRIT** | 旋转不变技术，免搜索 | 计算高效 | 需特定阵列结构(ULA/UCA) | Roy & Kailath (1989) [^4] |
| **ML** | 最大似然两级搜索（粗搜+细搜+插值） | **单快拍最优**，全局搜索天然解模糊 | 计算量大 | Stoica & Nehorai (1990) [^5] |
| **相位比较** | 阵元间相位差→方向余弦 | 实现简单，实时性好 | 存在相位模糊(d/λ>0.5) | 经典USBL文献 |
| **UCA模态MUSIC** | UCA→虚拟ULA变换后MUSIC | 解耦方位角和极角 | 阵元数限制模态阶数 | Mathews & Zoltowski (1994) [^6] |

#### CRB（Cramer-Rao下界）

$$\text{CRB}(\theta) = \frac{1}{2\text{SNR}} \cdot \frac{1}{\text{Re}\left[\mathbf{d}^H(\theta) \left(\mathbf{I} - \mathbf{a}(\mathbf{a}^H\mathbf{a})^{-1}\mathbf{a}^H\right) \mathbf{d}(\theta)\right]}$$

其中 $\mathbf{d}(\theta) = \partial\mathbf{a}/\partial\theta$ 为导向向量导数。

#### 宽带压缩感知DOA（最新进展）

> 2025年提出WCS-USBL方法：CSM（相干信号子空间法）聚焦子奈奎斯特采样信号 + 改进2D-SVD联合方位/俯仰角估计。
> 参考：[Ultra-short baseline underwater localization based on wideband compressed sensing](https://www.sciencedirect.com/science/article/abs/pii/S1051200425005470)

#### 稀疏自适应DOA

> 2022年Frontiers论文：基于稀疏自适应的水声信号高精度DOA估计，解决少快拍低信噪比场景。
> 参考：[High-precision DOA estimation based on sparsity adaptation](https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2022.1022494/full)

### 2.2 测距

$$R = \frac{c \cdot \Delta t}{2} \quad \text{(双程)} \quad \text{或} \quad R = c \cdot \Delta t \quad \text{(应答器单程)}$$

项目使用LFM匹配滤波测距：带宽4kHz，脉宽100ms，时间带宽积=400。

### 2.3 定位解算

已知斜距 $R$ 和方向 $(\theta, \phi)$：

$$\mathbf{p}_{\text{target}} = \mathbf{p}_{\text{array}} + R \cdot \mathbf{u}(\theta, \phi)$$

其中 $\mathbf{u} = [\sin\theta\cos\phi,\; \sin\theta\sin\phi,\; \cos\theta]^T$。

逆向USBL自定位：已知潜标位置，反算自身平台位置。

---

## 三、声线修正

直线传播假设在远距离/深水时误差显著。需要射线追踪修正。

### 等梯度声速模型

$$c(z) = c_0 + g \cdot (z - z_0)$$

声线轨迹为圆弧，曲率半径 $r = c / (g \cdot \cos\alpha)$。

### 射线追踪修正效果

> 组合射线追踪法：根据声速剖面梯度变化自动选择射线追踪方法，精度提升且计算量基本不变。
> 参考：[A Combined Ray Tracing Method for Improving USBL Precision](https://pmc.ncbi.nlm.nih.gov/articles/PMC6210799/) [^7]

> 两步修正法：基于现场声速测量，东/北/上方向精度分别提升8%/21%/26%。
> 参考：[Two-Step Correction Based on In-Situ Sound Speed](https://www.mdpi.com/2072-4292/15/20/5046) [^8]

> SINS/USBL紧耦合现场声速修正：海试RMS从0.45m→0.08m（北向），0.23m→0.07m（东向），精度提升80%+。
> 参考：[In-situ sound speed profile correction for SINS/USBL](https://link.springer.com/article/10.1186/s43020-025-00181-w) [^9]

---

## 四、安装校准

USBL换能器安装时无法与载体坐标系完全对齐，引入安装偏角误差（IMA），是**影响定位精度的主要系统误差**。

### 校准方法

| 方法 | 原理 | 参考 |
|------|------|------|
| **走圆校准（离线）** | 载体绕已知点走圆，最小二乘拟合偏角 | 杨保国论文 [^10] |
| **姿态确定法** | 基于SINS姿态信息标定安装偏角 | IEEE TIM (2020) [^11] |
| **加权TLS** | 同时考虑系数矩阵和观测误差 | 精度比LS提升8.75%，比未校准提升66% |
| **SVS平滑变结构** | 系统级安装参数（IMA+杠杆臂+应答器位置）联合标定 | IEEE JSEN (2023) [^12] |
| **IMM-UKF** | 交互多模型+无迹卡尔曼，同时估计应答器位置和安装参数 | IEEE TIM (2020) [^13] |
| **RDPSO优化** | 正则化离散粒子群优化系统级参数 | IEEE JSEN (2023) [^14] |
| **在线自校准** | EKF状态扩展，将偏角作为状态变量实时估计 | 项目Phase 3待做 |

> **项目参考文献**：杨保国《超短基线系统安装校准技术研究》、丁杰《复杂紧凑型超短基线定位及校准技术研究》

---

## 五、SINS/USBL组合导航

SINS（捷联惯导）提供高频姿态/加速度，USBL提供低频绝对位置，互补融合。

### 典型架构

```
SINS(高频,100Hz) ─→ 惯导解算 ─→ 位置/速度/姿态
                         ↓ (预测)
                   EKF/UKF 融合 ←── USBL(低频,0.1-1Hz) 斜距+DOA
                         ↓
                   校正后 位置/速度/姿态
                         ↓
               辅助传感器: 深度计 / DVL / GPS(水面)
```

### 关键文献

| 标题 | 期刊 | 年份 | 贡献 |
|------|------|------|------|
| Novel SINS/USBL tightly integrated navigation based on improved ANFIS | IEEE JSEN | 2022 | 自适应神经模糊推理紧耦合 [^15] |
| SINS/USBL calibration based on smooth variable structure | IEEE JSEN | 2023 | SVS滤波器联合标定 [^12] |
| SINS/DVL/USBL integrated navigation with federated KF | J. Cloud Computing | 2022 | 多源联邦卡尔曼 [^16] |
| IMM-UKF aided SINS/USBL calibration | IEEE TIM | 2020 | 交互多模型标定 [^13] |
| Polar SINS/USBL considering acoustic delay | IEEE OES | 2022 | 极地场景+通信延迟补偿 |

---

## 六、误差源与误差分配

| 误差源 | 量级 | 影响 | 抑制方法 |
|--------|------|------|---------|
| **DOA测量误差** | 0.1°-1° | 远距离放大 | ML/MUSIC + 多脉冲积累 |
| **测距误差** | ~0.1m | 固定偏差 | 匹配滤波 + 声速修正 |
| **安装偏角（IMA）** | 0.1°-0.5° | **系统性偏差** | 校准（走圆/在线） |
| **声速剖面误差** | 1-5 m/s | 射线弯曲 | 射线追踪 + 现场SVP |
| **多径效应** | 可变 | DOA偏差 | 波束形成/时间门控 |
| **平台运动** | 可变 | 积分时间内姿态变化 | IMU补偿 |
| **时间同步** | ~μs级 | 测距偏差 | PPS同步 |

> 项目误差分析（`error_budget_analysis.m`）结论：全距离范围优于0.5%，满足1%指标。

---

## 七、最新进展（2020-2025）

### 7.1 深度学习辅助

- LSTM网络补偿USBL非线性观测误差
- 深度学习辅助ES-EKF用于SINS/GPS/DVL融合

### 7.2 差分修正

> 差分法修正USBL结果：声速变化/射线弯曲/安装偏差的综合误差，MAE和标准差分别降低51.3%和55.3%。
> 参考：[Differential-based method for correcting USBL](https://www.sciencedirect.com/science/article/abs/pii/S0029801824013222) [^17]

### 7.3 全海深高精度

> LS-ESPRIT算法用于方阵USBL，结合波束跟踪和波束形成改善DOA精度。
> 参考：[High-Precision USBL for Full Sea Depth](https://www.mdpi.com/2077-1312/12/10/1689) [^18]

### 7.4 开源系统

> Raspi2USBL：基于Raspberry Pi的开源被动逆向USBL系统，方位精度0.1°，斜距精度0.1%。
> 代码：[github.com/ethanjinhuang/Raspi2USBL](https://github.com/ethanjinhuang/Raspi2USBL)
> 论文：[arXiv:2511.06998](https://arxiv.org/abs/2511.06998) [^19]

---

## 八、商用USBL系统

| 厂商 | 产品 | 精度 | 特点 |
|------|------|------|------|
| **Kongsberg** | HiPAP 502 | 斜距0.06% | 业界最高精度，240阵元球面阵 |
| **Sonardyne** | Ranger 2 | 斜距0.1% | Wideband 2技术，抗多径 |
| **iXblue (Exail)** | Gaps M7 | 斜距0.17% | 一体化设计，自动校准 |
| **LinkQuest** | TrackLink | 斜距0.25% | 宽带扩频，性价比高 |

---

## 参考文献

### 经典文献

[^1]: Van Trees, H.L. *Optimum Array Processing*. Wiley, 2002.
[^2]: Capon, J. "High-resolution frequency-wavenumber spectrum analysis." Proc. IEEE, 1969.
[^3]: Schmidt, R. "Multiple emitter location and signal parameter estimation." IEEE TAP, 1986.
[^4]: Roy, R. & Kailath, T. "ESPRIT — Estimation of signal parameters via rotational invariance techniques." IEEE TASSP, 1989.
[^5]: Stoica, P. & Nehorai, A. "Performance study of conditional and unconditional direction-of-arrival estimation." IEEE TASSP, 1990.
[^6]: Mathews, C.P. & Zoltowski, M.D. "Eigenstructure techniques for 2-D angle estimation with uniform circular arrays." IEEE TSP, 1994.

### 声线修正

[^7]: Chen, H. et al. "A combined ray tracing method for improving the precision of the USBL positioning system." Sensors, 2018.
[^8]: "Two-step correction based on in-situ sound speed measurements for USBL precise real-time positioning." Remote Sensing, 2023.
[^9]: "An in-situ sound speed profile correction scheme for SINS/USBL tight-coupling." Satellite Navigation, 2025.

### 校准

[^10]: 杨保国. "超短基线系统安装校准技术研究." 哈尔滨工程大学.
[^11]: "A calibration method of USBL installation error based on attitude determination." IEEE TIM, 2020.
[^12]: "A novel calibration algorithm of SINS/USBL navigation system based on smooth variable structure." IEEE JSEN, 2023.
[^13]: "An IMM-UKF aided SINS/USBL calibration solution for underwater vehicles." IEEE TIM, 2020.
[^14]: "A SINS/USBL system-level installation parameter calibration with improved RDPSO." IEEE JSEN, 2023.

### 组合导航

[^15]: "A novel SINS/USBL tightly integrated navigation strategy based on improved ANFIS." IEEE JSEN, 2022.
[^16]: "A SINS/DVL/USBL integrated navigation and positioning IoT system." J. Cloud Computing, 2022.

### 最新进展

[^17]: "A differential-based method for correcting ultra-short baseline positioning results." Ocean Engineering, 2024.
[^18]: "A high-precision ultra-short baseline positioning method for full sea depth." J. Marine Sci. Eng., 2024.
[^19]: Huang, E. et al. "Raspi2USBL: An open-source Raspberry Pi-based passive inverted USBL positioning system." arXiv:2511.06998, 2025.

### 项目已有中文论文

- 丁杰. "复杂紧凑型超短基线定位及校准技术研究."
- 杨保国. "超短基线系统安装校准技术研究."
- 蘧振超. "超短基线系统定位精度改进方法研究."
- 郑. "超短基线定位技术在水下潜器对接中的应用研究."

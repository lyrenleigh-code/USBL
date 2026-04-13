# USBL 自定位系统算法 — 任务跟踪

## 已完成

### Phase 0: 前期准备
- [x] 参考文献收集 (4篇USBL相关PDF)
- [x] 系统参数推演 (波长、基线比、模糊间距、波束宽度、链路预算)
- [x] 全链路算法架构设计

### Phase 1: 仿真环境搭建
- [x] 系统参数配置 (`usbl_config.m`)
- [x] 五元圆阵模型 (`create_uca5.m`, 含基线分析)
- [x] 导向向量计算 (`steering_vector.m`)
- [x] LFM信号生成 (`gen_lfm.m`)
- [x] 匹配滤波 (`matched_filter_lfm.m`)
- [x] 信道仿真 (`simulate_channel.m`, 含频域分数延迟)
- [x] 射线追踪 (`ray_trace.m`, 分层等梯度模型)
- [x] 坐标变换链 (`coordinate_transform.m` + `euler2rotmat.m`)
- [x] SNR模型修正: 应答器模式改为单程TL

### Phase 1.5: DOA算法调研
- [x] 少阵元DOA算法文献调研 (11种算法, 7大类)
- [x] CBF实现 (`doa_cbf.m`)
- [x] MVDR实现 (`doa_mvdr.m`)
- [x] MUSIC实现 (`doa_music.m`, 含前后向平均)
- [x] ML两级搜索实现 (`doa_ml.m`, 粗搜+细搜+插值)
- [x] 相位比较法实现 (`doa_phase_compare.m`, 含解模糊)
- [x] UCA模态MUSIC实现 (`doa_uca_mode_music.m`)
- [x] CRB计算 (`compute_doa_crb.m`)
- [x] DOA算法对比主脚本 (`run_doa_comparison.m`)
- [x] 平面阵秩亏修复: 相位比较法改为xy分量最小二乘 + 单位球约束恢复u_z
- [x] 算法选型结论: ML为主力, 相位比较为辅助

### Phase 1.5: 误差分析
- [x] 系统级误差分配分析 (`error_budget_analysis.m`)
- [x] 灵敏度分析 (`sensitivity_analysis.m`)
- [x] 误差分配主脚本 (`run_error_budget.m`)
- [x] 精度可达性论证: 全距离范围优于0.5%, 满足1%指标

### 文档输出
- [x] 初步技术方案 (Word文档, 9章完整版)

---

## 待完成

### Phase 2: 核心算法完善 (第2~4月)
- [ ] DOA仿真对比跑通并出报告 (运行run_doa_comparison, 记录结果)
- [ ] 全链路仿真跑通并出报告 (运行run_full_simulation, 验证端到端)
- [ ] 误差分配仿真跑通并出报告 (运行run_error_budget, 生成图表)
- [ ] ML算法优化: 加入多脉冲积累能力 (提升远距离SNR)
- [ ] 相位比较法: 加入多频解模糊选项 (作为备选解模糊方案)
- [ ] 匹配滤波加窗: 实现Hamming/Kaiser窗控制旁瓣 (抑制多径)
- [ ] 声线修正迭代反演: 已知斜距+DOA反推目标真实位置

### Phase 3: 系统级算法 (第4~6月)
- [ ] 多潜标融合定位算法 (`multi_buoy_solve.m`)
- [ ] GDOP分析工具 (分析潜标几何构型对定位精度的影响)
- [ ] 安装校准算法 — 离线走圆校准 (`install_calibration.m`)
- [ ] 安装校准算法 — 在线自校准 (EKF状态扩展)
- [ ] 导航滤波器 EKF (`ekf_navigation.m`)
- [ ] 野值剔除模块 (SNR门限 + 速度约束 + 多基线一致性 + 多潜标交叉验证)
- [ ] 平台运动补偿模块 (`motion_compensation.m`)
- [ ] 辅助传感器融合接口 (深度、DVL、IMU、GPS)

### Phase 4: 性能验证 (第6~8月)
- [ ] 蒙特卡洛仿真 (1000+次, 各距离/方向/海况)
- [ ] 多径信道模型 (海面/海底反射)
- [ ] 多径对DOA精度的影响分析
- [ ] 灵敏度分析报告 (各参数误差贡献)
- [ ] 全链路性能验证报告
- [ ] 算法冻结, 接口协议文档

### Phase 5: 工程化 (第8~10月)
- [ ] 与采集系统接口定义 (数据格式、时间同步协议)
- [ ] 与采集系统对接联调
- [ ] 实采数据回放处理验证
- [ ] C/C++移植可行性评估
- [ ] 实时性优化 (查找表、网格降采样等)

### Phase 6: 试验 (第10~12月)
- [ ] 湖试方案设计
- [ ] 湖试/海试
- [ ] 校准航次执行 + 校准流程固化
- [ ] 精度评估报告
- [ ] 生产测试规范
- [ ] 校准操作手册

---

## 技术债务 / 改进项
- [ ] ray_trace.m 极端声速剖面下的迭代保护
- [ ] simulate_channel.m 加入多径模型 (海面/海底反射)
- [ ] doa_ml.m 加入自适应网格细化 (低SNR时扩大搜索范围)
- [ ] 各DOA算法增加多信源支持 (为未来CDMA多目标同时定位预留)
- [ ] 仿真环境增加平台运动轨迹仿真 (航迹+姿态随时间变化)

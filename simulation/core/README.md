# simulation/core/

**基础模块**，按模块归属如下：

| 文件 | 归属模块 |
|------|---------|
| `create_uca5.m` | H2（阵列几何）+ M1（实测校正前阶段） |
| `steering_vector.m` | A2（DOA 共用） |
| `gen_lfm.m` | A1（信号生成） |
| `matched_filter_lfm.m` | A1（匹配滤波） |
| `simulate_channel.m` | S1（仿真平台，含信道） |
| `ray_trace.m` | A3（声速声线） |
| `coordinate_transform.m` | A4（坐标变换） |
| `euler2rotmat.m` | A4（工具函数） |

## 注意
- 本目录是**过渡组织**，理想状态是按模块编号重分（方案 2 彻底重组）
- 修改 core 文件前先查对应 spec 卡：`specs/active/<线>/<MOD>-*.md`
- 跨模块共用工具（如 `euler2rotmat`）修改需广播影响

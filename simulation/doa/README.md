# simulation/doa/

**A2: DOA 估计套件**专属目录。

| 文件 | 算法 |
|------|------|
| `doa_cbf.m` | 常规波束形成（粗估计/解模糊） |
| `doa_mvdr.m` | MVDR |
| `doa_music.m` | MUSIC（含前后向平均） |
| `doa_ml.m` | **ML 两级搜索（主力）** |
| `doa_phase_compare.m` | 相位比较（辅助，xy 最小二乘+球约束） |
| `doa_uca_mode_music.m` | UCA 模态 MUSIC |
| `compute_doa_crb.m` | CRB |

## 接口约定
统一接口：
```matlab
[theta_est, phi_est, P_spectrum] = doa_xxx(z, array, cfg, grid)
```

## 归属
- 模块 A2，详见 `specs/active/A/A2-doa-estimation.md`

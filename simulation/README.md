# simulation/

MATLAB 仿真代码根目录，对应模块线 **A（算法）** 和 **S（系统）**。

## 子目录归属

| 子目录 | 归属 |
|--------|------|
| `config/` | 跨模块共享 |
| `core/` | A1/A2/A3/A4 + S1 混合（过渡组织） |
| `doa/` | A2 专属 |
| `analysis/` | S1 主，跨模块用 |

## 主脚本（S1 仿真平台）

| 脚本 | 用途 |
|------|------|
| `run_doa_comparison.m` | DOA 算法对比 |
| `run_error_budget.m` | 误差分配可视化 |
| `run_full_simulation.m` | 全链路信号级仿真 |

## 运行约定

```matlab
addpath('config', 'core', 'doa', 'analysis');
```

## 相关

- 模块索引：`../TODO.md`
- Spec 卡：`../specs/active/A/`、`../specs/active/S/`
- 代码规则：`../.claude/rules/engineering.md`

## 规划中的子目录

- `fusion/` — A5 多潜标融合
- `nav/` — A6 组合导航
- 新增需在 `CLAUDE.md` 目录结构登记

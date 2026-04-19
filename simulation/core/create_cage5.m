function array = create_cage5(cfg)
% CREATE_CAGE5 创建笼式五元立体阵 (1 中央 + 4 外围立柱)
%
%   array = create_cage5(cfg)
%
%   对应物理原型：江苏水声技术有限公司 2026-04-15 工程图（版本 A），
%   见 [[five-element-transducer-assembly-drawing-vA]]。
%
%   阵型说明：
%     - 中央 1 个水听器（轴心方向安装）
%     - 外围 4 个水听器（均布于圆周，立柱式安装）
%     - 中央与外围水听器的轴向位置不同（双"水听器中心"标注 80 / 110 mm）
%     - z 轴沿立柱方向（阵面法线 = 地理系向下）
%
%   输入:
%     cfg - 系统参数结构体，可选字段：
%         cfg.array.cage_pos   - 5x3 显式坐标 (m)；若未提供则用**占位默认**
%         cfg.array.cage_radius_outer - 外围水听器环绕半径 (m), 默认 0.065
%         cfg.array.cage_z_center     - 中央水听器轴向位置 (m), 默认 0.080
%         cfg.array.cage_z_outer      - 外围水听器轴向位置 (m), 默认 0.110
%
%   输出:
%     array.pos       - 5x3 阵元位置矩阵 [x,y,z] (m)
%     array.N         - 阵元数 (5)
%     array.type      - 'CAGE5'
%     array.is_planar - false（立体阵，z 列非零，下游 DOA 相位比较走 3D LS）
%     array.baselines - 基线信息
%     array.pairs     - 所有阵元对索引
%
%   注意事项：
%   ℹ️ 默认几何为**标称设计坐标**（nominal design coordinates）：基于工程图
%      Z 标注（80/110 mm）+ 径向推算（75 mm）+ 4 方位均布假设。
%      2026-04-19 决策：**假定实际制造无误差**，即阵列几何 = 设计几何。
%      实际加工残差由 M2 电声一致性标定 + M4 在线重构补偿。
%   ⚠️ 与 UCA 不同，"短基线/长基线" 在立体阵中非等距分类——此处仍计算
%      所有基线但分类按"基线是否接近最小长度"近似标注。
%
%   示例：
%     % 用默认占位几何
%     cfg = usbl_config();
%     cfg.array.type = 'CAGE5';
%     array = create_cage5(cfg);
%
%     % 用显式坐标（推荐，待供应商图纸精确坐标到手后填入）
%     cfg.array.cage_pos = [
%         0,      0,     0.080;   % 中央
%         0.065,  0,     0.110;   % 外围 0°
%         0,      0.065, 0.110;   % 外围 90°
%        -0.065,  0,     0.110;   % 外围 180°
%         0,     -0.065, 0.110;   % 外围 270°
%     ];
%     array = create_cage5(cfg);

    %% 1. 入参解析 + 默认几何
    N = 5;

    if isfield(cfg.array, 'cage_pos') && ~isempty(cfg.array.cage_pos)
        pos = cfg.array.cage_pos;
        if ~isequal(size(pos), [N, 3])
            error('cfg.array.cage_pos 必须为 5x3 矩阵，当前 size = %s', mat2str(size(pos)));
        end
        geom_source = 'explicit cage_pos (nominal from usbl_config or user override)';
    else
        % === 回退默认（正常情况下 usbl_config 已填充 cage_pos）===
        z_center = get_field(cfg.array, 'cage_z_center', 0.080);
        z_outer  = get_field(cfg.array, 'cage_z_outer',  0.110);
        R_out    = get_field(cfg.array, 'cage_radius_outer', 0.075);
        pos = [
            0,        0,        z_center;    % 中央水听器（轴心）
            R_out,    0,        z_outer;     % 外围 0°
            0,        R_out,    z_outer;     % 外围 90°
           -R_out,    0,        z_outer;     % 外围 180°
            0,       -R_out,    z_outer];    % 外围 270°
        geom_source = sprintf('fallback nominal (R=%.3fm, z_c=%.3fm, z_o=%.3fm)', ...
                              R_out, z_center, z_outer);
    end

    %% 2. 参数校验
    if any(~isfinite(pos(:)))
        error('阵元坐标含非有限值');
    end
    pairwise_dist = pdist(pos);
    if min(pairwise_dist) < 1e-4
        warning('create_cage5:TooClose', '存在阵元间距 < 0.1 mm，几何可能异常');
    end

    %% 3. 核心字段
    array.pos       = pos;
    array.N         = N;
    array.type      = 'CAGE5';
    array.is_planar = false;   % z 列非零，下游相位比较走 3D LS 分支
    array.geom_source = geom_source;

    %% 4. 基线计算
    pairs = nchoosek(1:N, 2);  % C(5,2) = 10 对
    N_pairs = size(pairs, 1);

    baselines = struct();
    baselines.pairs   = pairs;
    baselines.N_pairs = N_pairs;
    baselines.vectors = zeros(N_pairs, 3);
    baselines.lengths = zeros(N_pairs, 1);
    baselines.azimuths_deg = zeros(N_pairs, 1);   % 水平方位
    baselines.elevations_deg = zeros(N_pairs, 1); % 立柱仰角
    baselines.d_over_lambda = zeros(N_pairs, 1);

    for p = 1:N_pairs
        i = pairs(p, 1);
        j = pairs(p, 2);
        d_vec = pos(i, :) - pos(j, :);
        baselines.vectors(p, :) = d_vec;
        baselines.lengths(p)    = norm(d_vec);
        baselines.azimuths_deg(p) = atan2d(d_vec(2), d_vec(1));
        baselines.elevations_deg(p) = atan2d(d_vec(3), hypot(d_vec(1), d_vec(2)));
        baselines.d_over_lambda(p) = baselines.lengths(p) / cfg.lambda;
    end

    % 立体阵无严格 "相邻/隔一" 分类。按最小基线近似标注 is_short。
    d_min = min(baselines.lengths);
    tol_rel = 0.05;  % 5% 容差
    baselines.is_short = abs(baselines.lengths - d_min) / d_min < tol_rel;
    baselines.is_long  = ~baselines.is_short;
    baselines.short_idx = find(baselines.is_short);
    baselines.long_idx  = find(baselines.is_long);

    array.baselines = baselines;
    array.pairs     = pairs;

    %% 5. 派生量
    array.aperture = max(baselines.lengths);     % 最大基线作孔径
    array.d_min    = d_min;
    array.d_max    = max(baselines.lengths);

    %% 6. 打印
    fprintf('===== 笼式五元立体阵参数 (CAGE5) =====\n');
    fprintf('几何来源: %s\n', geom_source);
    fprintf('阵元数: %d\n', N);
    fprintf('阵元坐标 (m):\n');
    for i = 1:N
        fprintf('  [%d] (%.4f, %.4f, %.4f)\n', i, pos(i,1), pos(i,2), pos(i,3));
    end
    fprintf('基线长度范围: %.1f ~ %.1f cm\n', d_min*100, array.d_max*100);
    fprintf('d_min/lambda = %.2f, d_max/lambda = %.2f\n', ...
            d_min/cfg.lambda, array.d_max/cfg.lambda);
    fprintf('最小基线条数 (近似相邻): %d / %d\n', ...
            sum(baselines.is_short), N_pairs);
    fprintf('====================================\n');
end


function v = get_field(s, name, default)
% 辅助：读结构体字段，缺失时返回 default
    if isfield(s, name) && ~isempty(s.(name))
        v = s.(name);
    else
        v = default;
    end
end

function array = create_uca5(cfg)
% CREATE_UCA5 创建五元均匀圆阵 (Uniform Circular Array)
%
%   array = create_uca5(cfg)
%
%   输入:
%     cfg - 系统参数结构体 (由 usbl_config 生成)
%
%   输出:
%     array.pos       - 5x3 阵元位置矩阵 [x,y,z] (m), 阵面在 xy 平面
%     array.N         - 阵元数 (5)
%     array.R_a       - 外接圆半径 (m)
%     array.baselines - 基线信息结构体
%     array.pairs     - 所有阵元对索引 (10x2)

    N = cfg.array.N_elements;
    R_a = cfg.array.R_a;

    %% 阵元位置 (正五边形, 阵面在xy平面, 法线沿z轴向下)
    % 第0个阵元在x轴正方向(前向)
    angles = (0:N-1)' * 2*pi/N;   % 各阵元的方位角
    pos = zeros(N, 3);
    pos(:,1) = R_a * cos(angles);  % x坐标
    pos(:,2) = R_a * sin(angles);  % y坐标
    pos(:,3) = 0;                  % z坐标 (同一平面)

    array.pos       = pos;
    array.N         = N;
    array.R_a       = R_a;
    array.angles    = angles;
    array.type      = 'UCA5';     % 供下游 DOA 算法 dispatch
    array.is_planar = true;       % z 列全零，下游相位比较走 xy + 球约束分支

    %% 计算所有基线
    pairs = nchoosek(1:N, 2);  % C(5,2) = 10 对
    N_pairs = size(pairs, 1);

    baselines = struct();
    baselines.pairs     = pairs;
    baselines.N_pairs   = N_pairs;
    baselines.vectors   = zeros(N_pairs, 3);  % 基线向量
    baselines.lengths   = zeros(N_pairs, 1);  % 基线长度
    baselines.azimuths  = zeros(N_pairs, 1);  % 基线方位角
    baselines.d_over_lambda = zeros(N_pairs, 1);

    for p = 1:N_pairs
        i = pairs(p, 1);
        j = pairs(p, 2);
        d_vec = pos(i,:) - pos(j,:);
        baselines.vectors(p,:) = d_vec;
        baselines.lengths(p)   = norm(d_vec);
        baselines.azimuths(p)  = atan2(d_vec(2), d_vec(1));
        baselines.d_over_lambda(p) = baselines.lengths(p) / cfg.lambda;
    end

    % 按基线长度分类: 短基线(相邻) 和 长基线(隔一)
    d_short = cfg.array.d;
    tol = 0.01;  % 1cm 容差
    baselines.is_short = abs(baselines.lengths - d_short) < tol;
    baselines.is_long  = ~baselines.is_short;
    baselines.short_idx = find(baselines.is_short);
    baselines.long_idx  = find(baselines.is_long);

    array.baselines = baselines;
    array.pairs     = pairs;

    %% 打印阵列信息
    fprintf('===== 五元均匀圆阵参数 =====\n');
    fprintf('阵元数: %d\n', N);
    fprintf('外接圆半径: %.1f cm\n', R_a*100);
    fprintf('阵列孔径: %.1f cm\n', 2*R_a*100);
    fprintf('相邻间距: %.1f cm (d/lambda = %.2f)\n', d_short*100, d_short/cfg.lambda);
    fprintf('短基线数: %d, 长度 %.1f cm\n', sum(baselines.is_short), d_short*100);
    fprintf('长基线数: %d, 长度 %.1f cm\n', sum(baselines.is_long), baselines.lengths(baselines.long_idx(1))*100);
    fprintf('短基线模糊间距: %.1f deg\n', cfg.array.ambiguity_short_deg);
    fprintf('波束宽度: %.1f deg\n', cfg.array.beamwidth_deg);
    fprintf('============================\n');
end

function [theta_est, phi_est, info] = doa_phase_compare(z, array, cfg, theta_init, phi_init)
% DOA_PHASE_COMPARE 经典相位比较法 DOA估计 (含解模糊)
%
%   这是传统USBL的标准DOA估计方法:
%   1. 提取各基线的相位差
%   2. 利用CBF或已知粗方向解模糊
%   3. 用所有基线的解模糊相位差做最小二乘DOA估计
%
%   适用性: USBL专用, 需要解模糊机制
%   优势:   物理意义清晰, 易于工程实现和调试
%   劣势:   d/lambda>0.5时需要解模糊, 解模糊失败会导致大误差
%
%   [theta_est, phi_est, info] = doa_phase_compare(z, array, cfg, theta_init, phi_init)
%
%   输入:
%     z          - Nx1 复数快拍
%     array      - 阵列结构体
%     cfg        - 系统参数
%     theta_init - (可选) 粗估计极角 (deg), 若无则用CBF
%     phi_init   - (可选) 粗估计方位角 (deg)

    k = cfg.derived.k;
    pos = array.pos;
    pairs = array.baselines.pairs;
    N_pairs = array.baselines.N_pairs;
    z_vec = z(:,1);

    %% 步骤1: 提取各基线测量相位差
    dphi_meas = zeros(N_pairs, 1);
    for p = 1:N_pairs
        i = pairs(p,1);
        j = pairs(p,2);
        dphi_meas(p) = angle(z_vec(i) * conj(z_vec(j)));
    end
    info.dphi_measured = dphi_meas;

    %% 步骤2: 获取粗方向 (用于解模糊)
    if nargin < 4 || isempty(theta_init)
        % 用CBF获取粗方向
        [theta_init, phi_init] = doa_cbf(z, array, cfg);
    end

    theta_init_r = deg2rad(theta_init);
    phi_init_r   = deg2rad(phi_init);

    %% 步骤3: 解相位模糊
    % 对每条基线, 根据粗方向计算理论相位差, 选择最近的模糊阶数
    u_init = [sin(theta_init_r)*cos(phi_init_r);
              sin(theta_init_r)*sin(phi_init_r);
              cos(theta_init_r)];

    dphi_pred = zeros(N_pairs, 1);
    n_ambiguity = zeros(N_pairs, 1);
    dphi_unwrap = zeros(N_pairs, 1);

    for p = 1:N_pairs
        i = pairs(p,1);
        j = pairs(p,2);
        d_vec = (pos(i,:) - pos(j,:))';
        dphi_pred(p) = k * d_vec' * u_init;
        n_ambiguity(p) = round((dphi_pred(p) - dphi_meas(p)) / (2*pi));
        dphi_unwrap(p) = dphi_meas(p) + 2*pi * n_ambiguity(p);
    end

    info.dphi_predicted = dphi_pred;
    info.n_ambiguity    = n_ambiguity;
    info.dphi_unwrapped = dphi_unwrap;

    %% 步骤4: 最小二乘DOA估计
    % 相位差模型: dphi_p = k * d_p^T * u(theta, phi)
    % 其中 u = [sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta)]^T
    %
    % 平面阵(所有阵元z=0): 基线向量z分量全为零, D_mat秩=2 → 仅解 u_x/u_y + 球约束恢复 u_z
    % 立体阵(z 列非零): D_mat 满秩 → 直接 3D LS 解 u，再归一化

    D_mat = zeros(N_pairs, 3);
    for p = 1:N_pairs
        i = pairs(p,1);
        j = pairs(p,2);
        D_mat(p,:) = pos(i,:) - pos(j,:);
    end

    % 判断是否平面阵：优先读 array.is_planar 标志，否则检查 z 列是否全零（容差 0.1 mm）
    if isfield(array, 'is_planar')
        is_planar = array.is_planar;
    else
        is_planar = max(abs(pos(:,3) - pos(1,3))) < 1e-4;
    end

    if is_planar
        % 平面阵：xy 最小二乘 + 球约束恢复 u_z
        D_xy = D_mat(:, 1:2);
        w_xy = D_xy \ dphi_unwrap;
        ux = w_xy(1) / k;
        uy = w_xy(2) / k;
        sin2_theta = ux^2 + uy^2;
        if sin2_theta > 1
            % 噪声导致超出单位球, 投影到球面
            scale = 1 / sqrt(sin2_theta);
            ux = ux * scale;
            uy = uy * scale;
            uz = 0;
        else
            uz = sqrt(1 - sin2_theta);  % 正值: 目标在阵法线方向(下方)
        end
    else
        % 立体阵：3D 最小二乘直解 + 归一化
        % u_unnorm = (D^T D)^-1 D^T dphi / k，再除以模长强制单位球
        w = D_mat \ dphi_unwrap;
        u_unnorm = w / k;
        u_norm = norm(u_unnorm);
        if u_norm < eps
            warning('doa_phase_compare:ZeroNorm', ...
                    '3D LS 解模长为 0，可能全部相位差为 0 或 D_mat 奇异');
            ux = 0; uy = 0; uz = 1;  % 回退阵法线
        else
            u_norm_vec = u_unnorm / u_norm;
            ux = u_norm_vec(1);
            uy = u_norm_vec(2);
            uz = u_norm_vec(3);
            % 强制 u_z >= 0（目标在阵法线方向下方的约束；若 uz<0 说明粗估解模糊错）
            if uz < 0
                uz = -uz; ux = -ux; uy = -uy;
            end
        end
    end

    u_est = [ux; uy; uz];
    theta_est = acosd(uz);
    phi_est   = mod(atan2d(uy, ux), 360);

    % 限制范围
    theta_est = max(0, min(90, theta_est));

    %% 步骤5: 残差分析 (用于质量评估)
    u_final = [sind(theta_est)*cosd(phi_est);
               sind(theta_est)*sind(phi_est);
               cosd(theta_est)];
    dphi_final = k * D_mat * u_final;
    residuals = dphi_unwrap - dphi_final;
    info.residuals = residuals;
    info.residual_rms = sqrt(mean(residuals.^2));
    info.residual_max = max(abs(residuals));
end

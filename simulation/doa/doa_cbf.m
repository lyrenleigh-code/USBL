function [theta_est, phi_est, P_spectrum] = doa_cbf(z, array, cfg, grid)
% DOA_CBF 常规波束形成 (Conventional Beamforming) DOA估计
%
%   适用性: 任意阵型, 单/多目标, 无需先验信息
%   优势:   实现简单, 鲁棒性强, 无模糊(分辨率内)
%   劣势:   角分辨率受阵列孔径限制 (~lambda/D)
%   本阵型分辨率: ~25°
%
%   [theta_est, phi_est, P_spectrum] = doa_cbf(z, array, cfg, grid)
%
%   输入:
%     z     - Nx1 复数快拍向量 (匹配滤波输出峰值处各通道复值)
%             或 NxK 多快拍矩阵
%     array - 阵列结构体
%     cfg   - 系统参数
%     grid  - (可选) 搜索网格结构体
%             .theta_vec - 极角搜索范围 (deg)
%             .phi_vec   - 方位角搜索范围 (deg)
%
%   输出:
%     theta_est  - 估计极角 (deg)
%     phi_est    - 估计方位角 (deg)
%     P_spectrum - 波束功率谱 (dB)

    k = cfg.derived.k;
    pos = array.pos;

    % 默认搜索网格
    if nargin < 4 || isempty(grid)
        grid.theta_vec = 0:cfg.sim.doa_grid_coarse:90;    % 极角 0~90°
        grid.phi_vec   = 0:cfg.sim.doa_grid_coarse:359;   % 方位角 0~360°
    end

    theta_vec = grid.theta_vec;
    phi_vec   = grid.phi_vec;
    N_theta = length(theta_vec);
    N_phi   = length(phi_vec);

    % 协方差矩阵
    if size(z, 2) > 1
        Rxx = (z * z') / size(z, 2);
    else
        Rxx = z * z';
    end

    % 波束扫描
    P_spectrum = zeros(N_theta, N_phi);
    for i = 1:N_theta
        theta_r = deg2rad(theta_vec(i));
        for j = 1:N_phi
            phi_r = deg2rad(phi_vec(j));
            a = steering_vector(theta_r, phi_r, pos, k);
            P_spectrum(i,j) = real(a' * Rxx * a);
        end
    end

    % 归一化为 dB
    P_max = max(P_spectrum(:));
    P_spectrum = 10*log10(P_spectrum / P_max + eps);

    % 找峰值
    [~, idx] = max(P_spectrum(:));
    [i_peak, j_peak] = ind2sub([N_theta, N_phi], idx);
    theta_est = theta_vec(i_peak);
    phi_est   = phi_vec(j_peak);
end

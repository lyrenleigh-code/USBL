function [theta_est, phi_est, P_spectrum] = doa_mvdr(z, array, cfg, grid)
% DOA_MVDR 最小方差无畸变响应 (MVDR/Capon) 波束形成 DOA估计
%
%   适用性: 任意阵型, 需要多快拍(或对角加载)
%   优势:   分辨率优于CBF, 自适应抑制干扰
%   劣势:   需要协方差矩阵可逆, 对模型失配敏感
%           对于少阵元(5)单快拍场景, 需要对角加载正则化
%
%   [theta_est, phi_est, P_spectrum] = doa_mvdr(z, array, cfg, grid)
%
%   输入/输出: 同 doa_cbf

    k = cfg.derived.k;
    pos = array.pos;
    N = array.N;

    if nargin < 4 || isempty(grid)
        grid.theta_vec = 0:cfg.sim.doa_grid_coarse:90;
        grid.phi_vec   = 0:cfg.sim.doa_grid_coarse:359;
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

    % 对角加载 (正则化, 防止奇异)
    % 加载量: 噪声功率估计或迹的比例
    load_level = trace(Rxx) / N * 0.01;  % 迹的1%
    Rxx_loaded = Rxx + load_level * eye(N);
    Rxx_inv = inv(Rxx_loaded);

    % MVDR 波束扫描
    P_spectrum = zeros(N_theta, N_phi);
    for i = 1:N_theta
        theta_r = deg2rad(theta_vec(i));
        for j = 1:N_phi
            phi_r = deg2rad(phi_vec(j));
            a = steering_vector(theta_r, phi_r, pos, k);
            P_spectrum(i,j) = 1 / real(a' * Rxx_inv * a + eps);
        end
    end

    P_max = max(P_spectrum(:));
    P_spectrum = 10*log10(P_spectrum / P_max + eps);

    [~, idx] = max(P_spectrum(:));
    [i_peak, j_peak] = ind2sub([N_theta, N_phi], idx);
    theta_est = theta_vec(i_peak);
    phi_est   = phi_vec(j_peak);
end

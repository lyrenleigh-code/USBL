function [theta_est, phi_est, P_spectrum] = doa_music(z, array, cfg, grid, n_src)
% DOA_MUSIC MUSIC (MUltiple SIgnal Classification) DOA估计
%
%   适用性: 任意阵型, 需要足够快拍以估计协方差矩阵
%   优势:   超分辨能力, 分辨率不受阵列孔径限制
%   劣势:   需要已知信源数, 需要足够的快拍数 (>N)
%           对于5元阵单快拍: 需要空间平滑或前后向平均增加自由度
%           少阵元时噪声子空间维数有限
%
%   [theta_est, phi_est, P_spectrum] = doa_music(z, array, cfg, grid, n_src)
%
%   输入:
%     z     - NxK 快拍矩阵 (K快拍)
%     array - 阵列结构体
%     cfg   - 系统参数
%     grid  - 搜索网格
%     n_src - (可选) 信源数, 默认1
%
%   输出: 同 doa_cbf

    k = cfg.derived.k;
    pos = array.pos;
    N = array.N;

    if nargin < 5 || isempty(n_src)
        n_src = 1;
    end

    if nargin < 4 || isempty(grid)
        grid.theta_vec = 0:cfg.sim.doa_grid_coarse:90;
        grid.phi_vec   = 0:cfg.sim.doa_grid_coarse:359;
    end

    theta_vec = grid.theta_vec;
    phi_vec   = grid.phi_vec;
    N_theta = length(theta_vec);
    N_phi   = length(phi_vec);

    % 协方差矩阵估计
    K = size(z, 2);
    if K >= N
        % 多快拍: 直接估计
        Rxx = (z * z') / K;
    else
        % 单快拍或少快拍: 用前后向平均增加秩
        Rxx = z * z';
        % 前后向平均 (FB averaging) — 利用UCA的中心对称性
        J = fliplr(eye(N));  % 交换矩阵
        Rxx_fb = 0.5 * (Rxx + J * conj(Rxx) * J);
        Rxx = Rxx_fb;
    end

    % 特征值分解
    [V, D] = eig(Rxx);
    [eigvals, idx] = sort(real(diag(D)), 'descend');
    V = V(:, idx);

    % 噪声子空间 (N-n_src 个最小特征值对应的特征向量)
    Un = V(:, n_src+1:end);

    % MUSIC 伪谱
    P_spectrum = zeros(N_theta, N_phi);
    for i = 1:N_theta
        theta_r = deg2rad(theta_vec(i));
        for j = 1:N_phi
            phi_r = deg2rad(phi_vec(j));
            a = steering_vector(theta_r, phi_r, pos, k);
            P_spectrum(i,j) = 1 / (real(a' * (Un * Un') * a) + eps);
        end
    end

    P_max = max(P_spectrum(:));
    P_spectrum = 10*log10(P_spectrum / P_max + eps);

    [~, peak_idx] = max(P_spectrum(:));
    [i_peak, j_peak] = ind2sub([N_theta, N_phi], peak_idx);
    theta_est = theta_vec(i_peak);
    phi_est   = phi_vec(j_peak);
end

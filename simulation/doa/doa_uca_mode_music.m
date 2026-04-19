function [theta_est, phi_est, P_spectrum] = doa_uca_mode_music(z, array, cfg, grid, n_src)
% DOA_UCA_MODE_MUSIC UCA相位模态MUSIC算法
%
%   利用均匀圆阵(UCA)的特殊结构, 通过DFT变换到相位模态域,
%   将UCA的阵列流形简化为Bessel函数形式, 然后在模态域应用MUSIC。
%
%   原理:
%     UCA导向向量: a_n(θ,φ) = exp(j*k*R*sin(θ)*cos(φ - 2πn/N))
%     经DFT变换后: ã_m(θ,φ) = j^m * J_m(kR*sinθ) * exp(-j*m*φ)
%     其中 J_m 是第一类Bessel函数
%
%   适用性: 仅适用于UCA, 可利用圆阵对称性提高性能
%   优势:   模态域导向向量解耦了θ和φ, 计算更高效
%           在模态域中相位模糊特性更清晰
%   劣势:   仅适用于UCA, 可用模态数受阵元数限制 (5元→模态-2到+2)
%
%   [theta_est, phi_est, P_spectrum] = doa_uca_mode_music(z, array, cfg, grid, n_src)

    % 阵型前置检查：Bessel 函数模型严格依赖等间距圆周几何
    if isfield(array, 'type') && ~strcmpi(array.type, 'UCA5')
        error('doa_uca_mode_music:WrongArrayType', ...
              ['doa_uca_mode_music 仅支持 UCA 阵型，当前 array.type=''%s''。\n' ...
               '立体阵请改用 doa_ml / doa_cbf / doa_music / doa_mvdr。'], ...
              array.type);
    end
    if isfield(array, 'is_planar') && ~array.is_planar
        error('doa_uca_mode_music:NotPlanar', ...
              '本算法要求阵面在 xy 平面（array.is_planar=true），立体阵不支持');
    end

    N = array.N;
    R_a = array.R_a;
    k = cfg.derived.k;

    if nargin < 5 || isempty(n_src), n_src = 1; end
    if nargin < 4 || isempty(grid)
        grid.theta_vec = 0:cfg.sim.doa_grid_coarse:90;
        grid.phi_vec   = 0:cfg.sim.doa_grid_coarse:359;
    end

    %% 步骤1: DFT变换到模态域
    % F = (1/sqrt(N)) * DFT矩阵
    F = fft(eye(N)) / sqrt(N);

    z_vec = z(:,1);
    z_mode = F * z_vec;  % 模态域快拍

    % 多快拍处理
    K = size(z, 2);
    if K > 1
        Z_mode = F * z;
        R_mode = (Z_mode * Z_mode') / K;
    else
        % 单快拍: 前后向平均
        R_mode = z_mode * z_mode';
        J = fliplr(eye(N));
        R_mode_fb = 0.5 * (R_mode + J * conj(R_mode) * J);
        R_mode = R_mode_fb;
    end

    %% 步骤2: 特征分解
    [V, D] = eig(R_mode);
    [~, idx] = sort(real(diag(D)), 'descend');
    V = V(:, idx);
    Un = V(:, n_src+1:end);  % 噪声子空间

    %% 步骤3: 在模态域构造导向向量并扫描
    % 模态域导向向量: ã_m = j^m * J_m(kR*sinθ) * exp(-j*m*φ)
    % 模态阶数: m = 0, 1, ..., N-1 (DFT索引), 对应物理模态 0, 1, 2, -2, -1
    % 重新排列为物理模态: m_phys = [0, 1, 2, -2, -1] → DFT idx [1, 2, 3, 4, 5]
    m_phys = [0, 1, 2, -(N-2), -(N-3)];  % 对N=5: [0,1,2,-2,-1]
    % 更通用:
    m_phys = mod((0:N-1) + floor(N/2), N) - floor(N/2);
    % 排列为 [0, 1, 2, -2, -1]

    theta_vec = grid.theta_vec;
    phi_vec   = grid.phi_vec;
    P_spectrum = zeros(length(theta_vec), length(phi_vec));

    for i = 1:length(theta_vec)
        theta_r = deg2rad(theta_vec(i));
        kR_sin = k * R_a * sin(theta_r);

        % Bessel函数值
        Jm = zeros(N, 1);
        for mi = 1:N
            m = mi - 1;  % DFT索引 0,1,...,N-1
            m_p = m_phys(mi);
            Jm(mi) = (1j)^m_p * besselj(m_p, kR_sin);
        end

        for j = 1:length(phi_vec)
            phi_r = deg2rad(phi_vec(j));

            % 模态域导向向量
            a_mode = zeros(N, 1);
            for mi = 1:N
                m_p = m_phys(mi);
                a_mode(mi) = Jm(mi) * exp(-1j * m_p * phi_r);
            end

            % MUSIC伪谱
            P_spectrum(i,j) = 1 / (real(a_mode' * (Un * Un') * a_mode) + eps);
        end
    end

    P_max = max(P_spectrum(:));
    P_spectrum = 10*log10(P_spectrum / P_max + eps);

    [~, peak_idx] = max(P_spectrum(:));
    [i_peak, j_peak] = ind2sub(size(P_spectrum), peak_idx);
    theta_est = theta_vec(i_peak);
    phi_est   = phi_vec(j_peak);
end

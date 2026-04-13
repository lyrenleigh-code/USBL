function [crb_theta_deg, crb_phi_deg, fim] = compute_doa_crb(theta_deg, phi_deg, snr_dB, array, cfg, K)
% COMPUTE_DOA_CRB 计算DOA估计的Cramér-Rao下界 (CRB)
%
%   CRB给出了无偏估计器方差的理论下限,是评价各算法性能的基准线
%
%   [crb_theta_deg, crb_phi_deg, fim] = compute_doa_crb(theta_deg, phi_deg, snr_dB, array, cfg, K)
%
%   输入:
%     theta_deg - 真实极角 (deg)
%     phi_deg   - 真实方位角 (deg)
%     snr_dB    - 信噪比 (dB), 匹配滤波后
%     array     - 阵列结构体
%     cfg       - 系统参数
%     K         - (可选) 快拍数, 默认1
%
%   输出:
%     crb_theta_deg - CRB(theta) 标准差 (deg)
%     crb_phi_deg   - CRB(phi) 标准差 (deg)
%     fim           - 2x2 Fisher信息矩阵

    if nargin < 6, K = 1; end

    k = cfg.derived.k;
    pos = array.pos;
    N = array.N;

    theta = deg2rad(theta_deg);
    phi   = deg2rad(phi_deg);
    snr = 10^(snr_dB/10);

    % 导向向量
    a = steering_vector(theta, phi, pos, k);

    % 导向向量对theta的偏导
    % u = [sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta)]
    % du/dtheta = [cos(theta)*cos(phi), cos(theta)*sin(phi), -sin(theta)]
    du_dtheta = [cos(theta)*cos(phi); cos(theta)*sin(phi); -sin(theta)];
    da_dtheta = 1j * k * (pos * du_dtheta) .* a;

    % 导向向量对phi的偏导
    % du/dphi = [-sin(theta)*sin(phi), sin(theta)*cos(phi), 0]
    du_dphi = [-sin(theta)*sin(phi); sin(theta)*cos(phi); 0];
    da_dphi = 1j * k * (pos * du_dphi) .* a;

    % 构造D矩阵 = [da/dtheta, da/dphi]
    D = [da_dtheta, da_dphi];

    % 投影矩阵: P_a_perp = I - a*(a'*a)^(-1)*a'
    Pa_perp = eye(N) - a * (a'*a)^(-1) * a';

    % Fisher信息矩阵 (Stoica & Nehorai, 1989)
    % FIM = (2*K*SNR) * Re{D' * Pa_perp * D}
    fim = 2 * K * snr * real(D' * Pa_perp * D);

    % CRB = FIM^(-1) 的对角线元素
    if rcond(fim) > eps
        crb = inv(fim);
        crb_theta = sqrt(abs(crb(1,1)));
        crb_phi   = sqrt(abs(crb(2,2)));
    else
        crb_theta = inf;
        crb_phi   = inf;
    end

    crb_theta_deg = rad2deg(crb_theta);
    crb_phi_deg   = rad2deg(crb_phi);
end

function [theta_est, phi_est, P_spectrum, info] = doa_ml(z, array, cfg, grid)
% DOA_ML 最大似然 (Maximum Likelihood) DOA估计 — 两级搜索策略
%
%   适用性: 任意阵型, 单快拍即可, 理论最优
%   优势:   达到CRB下界, 天然处理相位模糊(全局搜索),
%           对5元少阵元圆阵是最推荐的方法
%   劣势:   计算量大于CBF(但PC上完全可承受)
%
%   算法:
%     1) 粗搜索: 在全空间用 2°网格扫描, 找到全局峰值
%     2) 细搜索: 在峰值附近 ±3° 内用 0.05°网格精化
%     3) (可选) Newton迭代: 在细搜索基础上进一步精化
%
%   [theta_est, phi_est, P_spectrum, info] = doa_ml(z, array, cfg, grid)

    k = cfg.derived.k;
    pos = array.pos;

    %% === 第1级: 粗搜索 ===
    if nargin < 4 || isempty(grid)
        grid.theta_vec = 0:cfg.sim.doa_grid_coarse:90;
        grid.phi_vec   = 0:cfg.sim.doa_grid_coarse:359;
    end

    theta_c = grid.theta_vec;
    phi_c   = grid.phi_vec;

    % 对单快拍, ML准则: max |a'*z|^2 / (a'*a)
    % 对于UCA, a'*a = N (常数), 所以等价于 max |a'*z|^2
    z_vec = z(:, 1);  % 取第一个快拍

    P_coarse = zeros(length(theta_c), length(phi_c));
    for i = 1:length(theta_c)
        theta_r = deg2rad(theta_c(i));
        for j = 1:length(phi_c)
            phi_r = deg2rad(phi_c(j));
            a = steering_vector(theta_r, phi_r, pos, k);
            P_coarse(i,j) = abs(a' * z_vec)^2;
        end
    end

    [~, idx] = max(P_coarse(:));
    [i_coarse, j_coarse] = ind2sub(size(P_coarse), idx);
    theta_coarse = theta_c(i_coarse);
    phi_coarse   = phi_c(j_coarse);

    %% === 第2级: 细搜索 ===
    d_search = max(cfg.sim.doa_grid_coarse * 1.5, 3);  % 搜索范围 ±3°
    fine_step = cfg.sim.doa_grid_fine;

    theta_f = max(0, theta_coarse-d_search) : fine_step : min(90, theta_coarse+d_search);
    phi_f   = (phi_coarse-d_search) : fine_step : (phi_coarse+d_search);

    P_fine = zeros(length(theta_f), length(phi_f));
    for i = 1:length(theta_f)
        theta_r = deg2rad(theta_f(i));
        for j = 1:length(phi_f)
            phi_r = deg2rad(mod(phi_f(j), 360));
            a = steering_vector(theta_r, phi_r, pos, k);
            P_fine(i,j) = abs(a' * z_vec)^2;
        end
    end

    [~, idx] = max(P_fine(:));
    [i_fine, j_fine] = ind2sub(size(P_fine), idx);
    theta_est = theta_f(i_fine);
    phi_est   = mod(phi_f(j_fine), 360);

    %% === 第3级(可选): 基于梯度的精化 ===
    % 抛物线插值精化峰值位置
    if i_fine > 1 && i_fine < length(theta_f) && j_fine > 1 && j_fine < length(phi_f)
        % theta方向插值
        y = [P_fine(i_fine-1, j_fine), P_fine(i_fine, j_fine), P_fine(i_fine+1, j_fine)];
        delta_theta = 0.5 * (y(1) - y(3)) / (y(1) - 2*y(2) + y(3) + eps);
        theta_est = theta_est + delta_theta * fine_step;

        % phi方向插值
        y = [P_fine(i_fine, j_fine-1), P_fine(i_fine, j_fine), P_fine(i_fine, j_fine+1)];
        delta_phi = 0.5 * (y(1) - y(3)) / (y(1) - 2*y(2) + y(3) + eps);
        phi_est = mod(phi_est + delta_phi * fine_step, 360);
    end

    % 限制范围
    theta_est = max(0, min(90, theta_est));
    phi_est   = mod(phi_est, 360);

    % 输出粗搜索谱 (用于可视化)
    P_spectrum = 10*log10(P_coarse / max(P_coarse(:)) + eps);

    info.theta_coarse = theta_coarse;
    info.phi_coarse   = phi_coarse;
    info.P_fine       = P_fine;
end

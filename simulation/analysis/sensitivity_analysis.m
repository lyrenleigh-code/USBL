function results = sensitivity_analysis(cfg, array)
% SENSITIVITY_ANALYSIS 灵敏度分析 — 各参数对定位精度的影响
%
%   分析以下维度:
%   1. DOA估计精度 vs SNR (各算法CRB对比)
%   2. DOA估计精度 vs 目标方向 (θ依赖性)
%   3. 阵元间距对CRB的影响
%   4. 频率/带宽对各指标的影响
%
%   results = sensitivity_analysis(cfg, array)

    if nargin < 2
        array = create_uca5(cfg);
    end

    %% ===== 1. CRB vs SNR =====
    fprintf('===== CRB vs SNR 分析 =====\n');
    snr_vec = -5:1:35;
    theta_test = 30;  % deg
    phi_test = 45;

    crb_theta = zeros(length(snr_vec), 1);
    crb_phi   = zeros(length(snr_vec), 1);

    for si = 1:length(snr_vec)
        [crb_theta(si), crb_phi(si)] = compute_doa_crb(...
            theta_test, phi_test, snr_vec(si), array, cfg, 1);
    end

    results.snr_scan.snr_vec = snr_vec;
    results.snr_scan.crb_theta = crb_theta;
    results.snr_scan.crb_phi = crb_phi;

    % 标记关键SNR点
    target_accuracy = 0.3;  % deg
    idx_meet = find(crb_theta <= target_accuracy, 1);
    if ~isempty(idx_meet)
        fprintf('  DOA CRB ≤ %.1f° 所需最低SNR: %d dB (后MF)\n', ...
            target_accuracy, snr_vec(idx_meet));
        results.snr_scan.min_snr_for_target = snr_vec(idx_meet);
    end

    %% ===== 2. CRB vs 目标方向 =====
    fprintf('===== CRB vs 目标方向分析 =====\n');
    theta_scan = 1:1:85;
    phi_scan = [0, 36, 72, 90, 180];  % 选几个典型方位角
    snr_test = 16;  % dB, 对应约10km

    crb_vs_theta = zeros(length(theta_scan), length(phi_scan));
    for ti = 1:length(theta_scan)
        for pi_idx = 1:length(phi_scan)
            [crb_t, ~] = compute_doa_crb(theta_scan(ti), phi_scan(pi_idx), ...
                snr_test, array, cfg, 1);
            crb_vs_theta(ti, pi_idx) = crb_t;
        end
    end

    results.theta_scan.theta_vec = theta_scan;
    results.theta_scan.phi_vec = phi_scan;
    results.theta_scan.crb = crb_vs_theta;
    results.theta_scan.snr = snr_test;

    % 找最差方向
    [worst_crb, worst_idx] = max(crb_vs_theta(:));
    [wi, wj] = ind2sub(size(crb_vs_theta), worst_idx);
    fprintf('  SNR=%ddB时最差方向: θ=%.0f°, φ=%.0f° → CRB=%.2f°\n', ...
        snr_test, theta_scan(wi), phi_scan(wj), worst_crb);

    %% ===== 3. 阵元间距对性能的影响 =====
    fprintf('===== 阵元间距灵敏度分析 =====\n');
    d_scan = 0.05:0.01:0.40;  % 5cm to 40cm
    crb_vs_d = zeros(length(d_scan), 1);
    ambiguity_deg = zeros(length(d_scan), 1);

    for di = 1:length(d_scan)
        % 临时修改配置；本扫描专用于 UCA 阵型敏感度（立体阵的敏感度
        % 扫描维度更多，需另行设计）
        cfg_tmp = cfg;
        cfg_tmp.array.type = 'UCA5';
        cfg_tmp.array.d = d_scan(di);
        cfg_tmp.array.R_a = d_scan(di) / (2*sin(pi/5));
        cfg_tmp.array.aperture = 2 * cfg_tmp.array.R_a;
        cfg_tmp.array.d_over_lambda = d_scan(di) / cfg.lambda;
        % 用工厂统一构造阵列（输出含 is_planar / type 等字段）
        evalc('array_tmp = create_array(cfg_tmp);');  % 静默 fprintf

        [crb_vs_d(di), ~] = compute_doa_crb(theta_test, phi_test, ...
            snr_test, array_tmp, cfg, 1);

        % 相位模糊间距
        if d_scan(di) <= cfg.lambda
            ambiguity_deg(di) = asind(cfg.lambda / d_scan(di));
        else
            ambiguity_deg(di) = 0;  % 没有无模糊区
        end
    end

    results.d_scan.d_vec = d_scan;
    results.d_scan.crb = crb_vs_d;
    results.d_scan.ambiguity_deg = ambiguity_deg;
    results.d_scan.d_over_lambda = d_scan / cfg.lambda;

    % 找最优间距
    % 需要平衡: CRB越小越好(d越大), 但解模糊越难(d越大)
    % 实际约束: d/lambda < 2~3 时解模糊可靠
    feasible = d_scan/cfg.lambda <= 2.5;
    [best_crb, best_idx] = min(crb_vs_d(feasible));
    d_feasible = d_scan(feasible);
    fprintf('  d/λ≤2.5约束下最优间距: %.1fcm (d/λ=%.2f), CRB=%.3f°\n', ...
        d_feasible(best_idx)*100, d_feasible(best_idx)/cfg.lambda, best_crb);
    fprintf('  当前间距 %.0fcm: d/λ=%.2f, CRB=%.3f° (SNR=%ddB)\n', ...
        cfg.array.d*100, cfg.array.d_over_lambda, ...
        crb_vs_d(find(abs(d_scan-cfg.array.d)<0.005,1)), snr_test);

    %% ===== 4. 多快拍积累效果 =====
    fprintf('===== 多快拍积累效果 =====\n');
    K_scan = [1, 2, 4, 8, 16, 32];
    crb_vs_K = zeros(length(K_scan), 1);
    for ki = 1:length(K_scan)
        [crb_vs_K(ki), ~] = compute_doa_crb(theta_test, phi_test, ...
            snr_test, array, cfg, K_scan(ki));
    end

    results.K_scan.K_vec = K_scan;
    results.K_scan.crb = crb_vs_K;

    fprintf('  快拍数  CRB(θ)\n');
    for ki = 1:length(K_scan)
        fprintf('  %4d    %.3f°\n', K_scan(ki), crb_vs_K(ki));
    end
    fprintf('  (注意: USBL应答模式通常仅1个快拍, 多快拍需要特殊信号设计)\n');

    fprintf('\n===== 灵敏度分析完成 =====\n');
end

%% RUN_FULL_SIMULATION  USBL全链路仿真 (信号级)
%
%  完整流程:
%    发射LFM信号 → 信道传播 → 5通道接收 → 匹配滤波 → 时延估计(测距)
%    → 提取复快拍 → DOA估计 → 坐标变换 → 定位解算
%
%  用于验证端到端性能, 与窄带模型对比
%
%  Author: USBL Algorithm Team
%  Date: 2026-03

clear; close all; clc;

%% 添加路径
addpath('config', 'core', 'doa', 'analysis');

%% 初始化
cfg = usbl_config();
array = create_uca5(cfg);

%% 场景设置
% 潜标位置 (NED坐标, 相对于平台)
targets = struct();
targets(1).range     = 1000;    % 斜距 (m)
targets(1).theta_deg = 25;      % 极角 (deg)
targets(1).phi_deg   = 60;      % 方位角 (deg)
targets(1).name      = '潜标#1 (1km)';

targets(2).range     = 5000;
targets(2).theta_deg = 35;
targets(2).phi_deg   = 150;
targets(2).name      = '潜标#2 (5km)';

targets(3).range     = 10000;
targets(3).theta_deg = 30;
targets(3).phi_deg   = 45;
targets(3).name      = '潜标#3 (10km)';

% 生成发射信号
[s_tx, t_tx] = gen_lfm(cfg);

fprintf('===== USBL 全链路信号级仿真 =====\n');
fprintf('信号: LFM, fc=%.0fkHz, BW=%.0fkHz, T=%.0fms\n', ...
    cfg.fc/1e3, cfg.signal.bw/1e3, cfg.signal.duration*1e3);
fprintf('处理增益: %.1f dB\n', cfg.signal.proc_gain_dB);
fprintf('\n');

%% 搜索网格
grid.theta_vec = 0:2:90;
grid.phi_vec   = 0:2:359;

%% 蒙特卡洛仿真
N_mc = 100;
N_targets = length(targets);

results = struct();

for ti = 1:N_targets
    target = targets(ti);
    fprintf('--- %s (R=%dm, θ=%.0f°, φ=%.0f°) ---\n', ...
        target.name, target.range, target.theta_deg, target.phi_deg);

    est_R     = zeros(N_mc, 1);
    est_theta = zeros(N_mc, 1);
    est_phi   = zeros(N_mc, 1);

    for mc = 1:N_mc
        %% 1. 信道仿真 → 接收信号
        [x_rx, ch_info] = simulate_channel(s_tx, cfg, array, target);

        %% 2. 匹配滤波
        [mf_out, mf_env] = matched_filter_lfm(x_rx, s_tx);

        %% 3. 时延估计 → 测距
        % 以通道1为参考, 找匹配滤波包络峰值
        [peak_val, peak_idx] = max(mf_env(1,:));

        % 抛物线插值精化
        if peak_idx > 1 && peak_idx < size(mf_env, 2)
            y = mf_env(1, peak_idx-1:peak_idx+1);
            delta = 0.5 * (y(1) - y(3)) / (y(1) - 2*y(2) + y(3) + eps);
        else
            delta = 0;
        end
        tau_est = (peak_idx + delta - 1) / cfg.signal.fs;

        % 信号长度补偿 (匹配滤波输出峰值位于信号末尾)
        tau_est = tau_est - (length(s_tx) - 1) / cfg.signal.fs;

        % 转为双程距离→单程斜距
        % (此仿真中tau_est对应单程延迟差, 因为仅仿真了单程传播)
        % 实际系统中需除以2并减去应答器延迟
        est_R(mc) = tau_est * cfg.c;

        %% 4. 提取复快拍 → DOA估计
        % 在峰值位置提取各通道的复数值
        z = zeros(array.N, 1);
        for ch = 1:array.N
            % 对每个通道找各自的峰值(可能因延迟差异略有偏移)
            search_range = max(1, peak_idx-5) : min(size(mf_out,2), peak_idx+5);
            [~, local_peak] = max(abs(mf_out(ch, search_range)));
            z(ch) = mf_out(ch, search_range(local_peak));
        end

        % ML DOA估计
        [est_theta(mc), est_phi(mc)] = doa_ml(z, array, cfg, grid);
    end

    %% 统计
    % 测距
    err_R = est_R - target.range;
    rmse_R = sqrt(mean(err_R.^2));
    bias_R = mean(err_R);

    % 测角
    err_theta = est_theta - target.theta_deg;
    err_phi = mod(est_phi - target.phi_deg + 180, 360) - 180;

    % 排除解模糊失败
    fail_mask = abs(err_theta) > 10 | abs(err_phi) > 10;
    n_fail = sum(fail_mask);
    valid = ~fail_mask;

    if sum(valid) > 0
        rmse_theta = sqrt(mean(err_theta(valid).^2));
        rmse_phi   = sqrt(mean(err_phi(valid).^2));
    else
        rmse_theta = NaN;
        rmse_phi = NaN;
    end

    % 横向误差
    cross_err = target.range * deg2rad(sqrt(err_theta(valid).^2 + err_phi(valid).^2));
    rmse_cross = sqrt(mean(cross_err.^2));

    % 总误差
    total_err = sqrt(err_R(valid).^2 + cross_err.^2);
    rmse_total = sqrt(mean(total_err.^2));

    % CRB参考
    [crb_t, crb_p] = compute_doa_crb(target.theta_deg, target.phi_deg, ...
        ch_info.snr_post_mf_dB, array, cfg, 1);

    fprintf('  SNR(后MF): %.1f dB\n', ch_info.snr_post_mf_dB);
    fprintf('  测距 RMSE: %.2f m (偏差: %.2f m, 相对: %.3f%%)\n', ...
        rmse_R, bias_R, rmse_R/target.range*100);
    fprintf('  DOA  RMSE: θ=%.3f° φ=%.3f°  CRB: θ=%.3f° φ=%.3f°\n', ...
        rmse_theta, rmse_phi, crb_t, crb_p);
    fprintf('  横向 RMSE: %.2f m\n', rmse_cross);
    fprintf('  总   RMSE: %.2f m (%.3f%%)\n', rmse_total, rmse_total/target.range*100);
    fprintf('  解模糊失败: %d/%d (%.1f%%)\n', n_fail, N_mc, n_fail/N_mc*100);
    fprintf('\n');

    results(ti).target = target;
    results(ti).rmse_R = rmse_R;
    results(ti).rmse_theta = rmse_theta;
    results(ti).rmse_phi = rmse_phi;
    results(ti).rmse_total = rmse_total;
    results(ti).snr_post = ch_info.snr_post_mf_dB;
    results(ti).n_fail = n_fail;
end

%% 汇总表
fprintf('┌──────────────┬─────────┬──────────┬──────────┬──────────┬─────────┐\n');
fprintf('│ 目标         │SNR(dB)  │测距RMSE  │DOA RMSE  │总RMSE    │占斜距%%  │\n');
fprintf('├──────────────┼─────────┼──────────┼──────────┼──────────┼─────────┤\n');
for ti = 1:N_targets
    fprintf('│ %-12s │ %5.1f   │ %6.2fm  │ %6.3f°  │ %7.2fm │ %5.3f%%  │\n', ...
        results(ti).target.name, results(ti).snr_post, results(ti).rmse_R, ...
        results(ti).rmse_theta, results(ti).rmse_total, ...
        results(ti).rmse_total/results(ti).target.range*100);
end
fprintf('└──────────────┴─────────┴──────────┴──────────┴──────────┴─────────┘\n');

save('full_simulation_results.mat', 'results');
fprintf('\n仿真完成, 结果已保存。\n');

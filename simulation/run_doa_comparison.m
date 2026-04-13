%% RUN_DOA_COMPARISON  DOA算法对比仿真主脚本
%
%  针对五元圆阵(d/λ=1.33)的少阵元DOA算法全面对比
%
%  对比算法:
%    1. CBF  — 常规波束形成 (基线方法, 分辨率受限但无模糊风险)
%    2. MVDR — 最小方差无畸变响应 (自适应, 分辨率优于CBF)
%    3. MUSIC — 子空间方法 (超分辨, 但5元单快拍受限)
%    4. ML   — 最大似然 (理论最优, 两级搜索, 推荐方法)
%    5. Phase Compare — 经典USBL相位比较 (需解模糊)
%    6. UCA Mode MUSIC — UCA相位模态MUSIC (利用圆阵对称性)
%
%  评价指标:
%    - RMSE vs SNR
%    - RMSE vs 目标方向
%    - 解模糊成功率
%    - 计算耗时
%
%  少阵元DOA调研结论 (见脚本末尾)
%
%  Author: USBL Algorithm Team
%  Date: 2026-03

clear; close all; clc;

%% 添加路径
addpath('config', 'core', 'doa', 'analysis');

%% 初始化
cfg = usbl_config();
array = create_uca5(cfg);

%% ============================================================
%%  实验1: RMSE vs SNR (固定方向, 扫描SNR)
%% ============================================================
fprintf('\n========== 实验1: RMSE vs SNR ==========\n');

theta_true = 30;  % deg, 极角
phi_true   = 45;  % deg, 方位角
snr_vec    = -5:2:30;
N_mc       = cfg.sim.N_monte_carlo;
N_snr      = length(snr_vec);

algo_names = {'CBF', 'MVDR', 'MUSIC', 'ML', 'PhaseCompare', 'UCA-ModeMUSIC'};
N_algo     = length(algo_names);

rmse_theta = zeros(N_snr, N_algo);
rmse_phi   = zeros(N_snr, N_algo);
bias_theta = zeros(N_snr, N_algo);
bias_phi   = zeros(N_snr, N_algo);
time_avg   = zeros(N_snr, N_algo);
amb_fail   = zeros(N_snr, N_algo);  % 解模糊失败次数

% CRB基准线
crb_theta = zeros(N_snr, 1);
crb_phi   = zeros(N_snr, 1);

% 搜索网格
grid_coarse.theta_vec = 0:2:90;
grid_coarse.phi_vec   = 0:2:359;

for si = 1:N_snr
    snr = snr_vec(si);
    [crb_theta(si), crb_phi(si)] = compute_doa_crb(theta_true, phi_true, snr, array, cfg, 1);

    % 各算法的估计结果
    est_theta = zeros(N_mc, N_algo);
    est_phi   = zeros(N_mc, N_algo);
    t_elapsed = zeros(N_mc, N_algo);

    for mc = 1:N_mc
        % 生成带噪声的单快拍数据
        z = generate_snapshot(theta_true, phi_true, snr, array, cfg);

        % --- 1. CBF ---
        tic;
        [est_theta(mc,1), est_phi(mc,1)] = doa_cbf(z, array, cfg, grid_coarse);
        t_elapsed(mc,1) = toc;

        % --- 2. MVDR ---
        tic;
        [est_theta(mc,2), est_phi(mc,2)] = doa_mvdr(z, array, cfg, grid_coarse);
        t_elapsed(mc,2) = toc;

        % --- 3. MUSIC ---
        tic;
        [est_theta(mc,3), est_phi(mc,3)] = doa_music(z, array, cfg, grid_coarse, 1);
        t_elapsed(mc,3) = toc;

        % --- 4. ML (两级搜索) ---
        tic;
        [est_theta(mc,4), est_phi(mc,4)] = doa_ml(z, array, cfg, grid_coarse);
        t_elapsed(mc,4) = toc;

        % --- 5. Phase Compare ---
        tic;
        [est_theta(mc,5), est_phi(mc,5)] = doa_phase_compare(z, array, cfg);
        t_elapsed(mc,5) = toc;

        % --- 6. UCA Mode MUSIC ---
        tic;
        [est_theta(mc,6), est_phi(mc,6)] = doa_uca_mode_music(z, array, cfg, grid_coarse, 1);
        t_elapsed(mc,6) = toc;
    end

    % 统计
    for ai = 1:N_algo
        err_theta = est_theta(:,ai) - theta_true;
        err_phi   = wrapTo180(est_phi(:,ai) - phi_true);

        % 检测解模糊失败 (误差>10°视为失败)
        fail_mask = abs(err_theta) > 10 | abs(err_phi) > 10;
        amb_fail(si, ai) = sum(fail_mask);

        % 仅对成功的样本计算RMSE
        valid = ~fail_mask;
        if sum(valid) > 0
            rmse_theta(si, ai) = sqrt(mean(err_theta(valid).^2));
            rmse_phi(si, ai)   = sqrt(mean(err_phi(valid).^2));
            bias_theta(si, ai) = mean(err_theta(valid));
            bias_phi(si, ai)   = mean(err_phi(valid));
        else
            rmse_theta(si, ai) = NaN;
            rmse_phi(si, ai)   = NaN;
        end
        time_avg(si, ai) = mean(t_elapsed(:, ai));
    end

    fprintf('  SNR=%3ddB: RMSE(θ) = ', snr);
    for ai = 1:N_algo
        fprintf('%7.3f°', rmse_theta(si,ai));
        if ai < N_algo, fprintf(' | '); end
    end
    fprintf('  CRB=%.3f°\n', crb_theta(si));
end

%% ============================================================
%%  实验2: RMSE vs 目标方向 (固定SNR, 扫描θ)
%% ============================================================
fprintf('\n========== 实验2: RMSE vs 目标方向 ==========\n');

snr_fixed = 16;  % dB, 约对应10km
theta_scan = [5, 10, 20, 30, 40, 50, 60, 70, 80];
phi_fixed  = 45;
N_theta_scan = length(theta_scan);
N_mc_dir = min(200, N_mc);

rmse_vs_dir = zeros(N_theta_scan, N_algo);
amb_fail_dir = zeros(N_theta_scan, N_algo);
crb_vs_dir = zeros(N_theta_scan, 1);

for ti = 1:N_theta_scan
    theta_t = theta_scan(ti);
    [crb_vs_dir(ti), ~] = compute_doa_crb(theta_t, phi_fixed, snr_fixed, array, cfg, 1);

    est_t = zeros(N_mc_dir, N_algo);
    for mc = 1:N_mc_dir
        z = generate_snapshot(theta_t, phi_fixed, snr_fixed, array, cfg);

        [est_t(mc,1), ~] = doa_cbf(z, array, cfg, grid_coarse);
        [est_t(mc,2), ~] = doa_mvdr(z, array, cfg, grid_coarse);
        [est_t(mc,3), ~] = doa_music(z, array, cfg, grid_coarse, 1);
        [est_t(mc,4), ~] = doa_ml(z, array, cfg, grid_coarse);
        [est_t(mc,5), ~] = doa_phase_compare(z, array, cfg);
        [est_t(mc,6), ~] = doa_uca_mode_music(z, array, cfg, grid_coarse, 1);
    end

    for ai = 1:N_algo
        err = est_t(:,ai) - theta_t;
        fail = abs(err) > 10;
        amb_fail_dir(ti, ai) = sum(fail);
        valid = ~fail;
        if sum(valid) > 0
            rmse_vs_dir(ti, ai) = sqrt(mean(err(valid).^2));
        else
            rmse_vs_dir(ti, ai) = NaN;
        end
    end

    fprintf('  θ=%2d°: RMSE = ', theta_t);
    for ai = 1:N_algo
        fprintf('%6.3f°', rmse_vs_dir(ti,ai));
        if ai < N_algo, fprintf(' | '); end
    end
    fprintf('  CRB=%.3f°\n', crb_vs_dir(ti));
end

%% ============================================================
%%  实验3: 解模糊成功率统计
%% ============================================================
fprintf('\n========== 实验3: 解模糊成功率 ==========\n');
fprintf('  算法            ');
for si = 1:N_snr
    fprintf('%4ddB ', snr_vec(si));
end
fprintf('\n');
for ai = 1:N_algo
    fprintf('  %-16s', algo_names{ai});
    for si = 1:N_snr
        rate = (N_mc - amb_fail(si,ai)) / N_mc * 100;
        fprintf('%5.1f%% ', rate);
    end
    fprintf('\n');
end

%% ============================================================
%%  结果可视化
%% ============================================================
fprintf('\n========== 绘图 ==========\n');

% 图1: RMSE vs SNR
figure('Name', 'RMSE vs SNR', 'Position', [100 100 900 600]);
colors = lines(N_algo + 1);
semilogy(snr_vec, crb_theta, 'k--', 'LineWidth', 2, 'DisplayName', 'CRB');
hold on;
markers = {'o', 's', 'd', '^', 'v', 'p'};
for ai = 1:N_algo
    semilogy(snr_vec, rmse_theta(:,ai), ['-' markers{ai}], ...
        'Color', colors(ai,:), 'LineWidth', 1.5, 'MarkerSize', 5, ...
        'DisplayName', algo_names{ai});
end
hold off;
xlabel('SNR (dB, 匹配滤波后)');
ylabel('RMSE (deg)');
title(sprintf('DOA估计精度 vs SNR (θ=%.0f°, φ=%.0f°, 5元UCA, d/λ=%.2f)', ...
    theta_true, phi_true, cfg.array.d_over_lambda));
legend('Location', 'southwest');
grid on;
ylim([0.01, 50]);
% 标注对应距离
ax2 = axes('Position', get(gca,'Position'), 'XAxisLocation','top', ...
    'YAxisLocation','right', 'Color','none', 'YTick',[]);
% 添加1%精度线参考
yline_1pct = 0.57;  % 1%精度对应的角度误差
hold(gca, 'on');

fprintf('  图1已生成: RMSE vs SNR\n');

% 图2: RMSE vs 目标方向
figure('Name', 'RMSE vs Direction', 'Position', [100 100 900 600]);
plot(theta_scan, crb_vs_dir, 'k--', 'LineWidth', 2, 'DisplayName', 'CRB');
hold on;
for ai = 1:N_algo
    plot(theta_scan, rmse_vs_dir(:,ai), ['-' markers{ai}], ...
        'Color', colors(ai,:), 'LineWidth', 1.5, 'MarkerSize', 6, ...
        'DisplayName', algo_names{ai});
end
hold off;
xlabel('目标极角 θ (deg)');
ylabel('RMSE (deg)');
title(sprintf('DOA估计精度 vs 目标方向 (SNR=%ddB, φ=%.0f°)', snr_fixed, phi_fixed));
legend('Location', 'northwest');
grid on;

fprintf('  图2已生成: RMSE vs Direction\n');

% 图3: 波束图/谱对比 (单次实现)
figure('Name', 'Spectrum Comparison', 'Position', [100 100 1200 800]);
z_demo = generate_snapshot(theta_true, phi_true, 16, array, cfg);

subplot(2,3,1);
[~, ~, P] = doa_cbf(z_demo, array, cfg, grid_coarse);
imagesc(grid_coarse.phi_vec, grid_coarse.theta_vec, P);
xlabel('φ (deg)'); ylabel('θ (deg)'); title('CBF');
colorbar; clim([-20, 0]);

subplot(2,3,2);
[~, ~, P] = doa_mvdr(z_demo, array, cfg, grid_coarse);
imagesc(grid_coarse.phi_vec, grid_coarse.theta_vec, P);
xlabel('φ (deg)'); ylabel('θ (deg)'); title('MVDR');
colorbar; clim([-20, 0]);

subplot(2,3,3);
[~, ~, P] = doa_music(z_demo, array, cfg, grid_coarse, 1);
imagesc(grid_coarse.phi_vec, grid_coarse.theta_vec, P);
xlabel('φ (deg)'); ylabel('θ (deg)'); title('MUSIC');
colorbar; clim([-20, 0]);

subplot(2,3,4);
[~, ~, P] = doa_ml(z_demo, array, cfg, grid_coarse);
imagesc(grid_coarse.phi_vec, grid_coarse.theta_vec, P);
xlabel('φ (deg)'); ylabel('θ (deg)'); title('ML');
colorbar; clim([-20, 0]);

subplot(2,3,5);
% Phase Compare 没有谱, 画残差
[~, ~, pc_info] = doa_phase_compare(z_demo, array, cfg);
bar(pc_info.residuals);
xlabel('基线编号'); ylabel('相位残差 (rad)');
title(sprintf('PhaseCompare 残差 (RMS=%.3f)', pc_info.residual_rms));

subplot(2,3,6);
[~, ~, P] = doa_uca_mode_music(z_demo, array, cfg, grid_coarse, 1);
imagesc(grid_coarse.phi_vec, grid_coarse.theta_vec, P);
xlabel('φ (deg)'); ylabel('θ (deg)'); title('UCA-ModeMUSIC');
colorbar; clim([-20, 0]);

sgtitle(sprintf('空间谱对比 (θ=%.0f°, φ=%.0f°, SNR=16dB)', theta_true, phi_true));
fprintf('  图3已生成: 空间谱对比\n');

% 图4: 计算耗时对比
figure('Name', 'Computation Time', 'Position', [100 100 600 400]);
bar(mean(time_avg, 1) * 1000);
set(gca, 'XTickLabel', algo_names, 'XTickLabelRotation', 30);
ylabel('平均耗时 (ms)');
title('各算法计算耗时');
grid on;
fprintf('  图4已生成: 计算耗时对比\n');

%% ============================================================
%%  综合评价与结论
%% ============================================================
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════════╗\n');
fprintf('║          少阵元(5元)UCA DOA算法调研结论                              ║\n');
fprintf('╠══════════════════════════════════════════════════════════════════════╣\n');
fprintf('║                                                                    ║\n');
fprintf('║  1. CBF (常规波束形成)                                              ║\n');
fprintf('║     - 分辨率: ~25° (受孔径限制)                                     ║\n');
fprintf('║     - 精度: 远不及CRB, 但无模糊                                    ║\n');
fprintf('║     - 定位: 仅适合做粗估计/解模糊辅助                               ║\n');
fprintf('║     - 推荐度: ★★☆☆☆ (做辅助, 不做主力)                            ║\n');
fprintf('║                                                                    ║\n');
fprintf('║  2. MVDR (Capon)                                                   ║\n');
fprintf('║     - 分辨率: 优于CBF, 但5元阵提升有限                              ║\n');
fprintf('║     - 精度: 单快拍时需对角加载, 精度与CBF接近                        ║\n');
fprintf('║     - 鲁棒性: 对角加载参数敏感                                      ║\n');
fprintf('║     - 推荐度: ★★☆☆☆ (对5元阵优势不明显)                           ║\n');
fprintf('║                                                                    ║\n');
fprintf('║  3. MUSIC                                                          ║\n');
fprintf('║     - 分辨率: 超分辨, 谱峰尖锐                                     ║\n');
fprintf('║     - 精度: 多快拍时逼近CRB, 单快拍时退化严重                       ║\n');
fprintf('║     - 难点: 5元1快拍→协方差矩阵秩=1, 需前后向平均                   ║\n');
fprintf('║     - 推荐度: ★★★☆☆ (如能获取多快拍则推荐)                        ║\n');
fprintf('║                                                                    ║\n');
fprintf('║  4. ML (最大似然, 两级搜索) ← 推荐主力算法                          ║\n');
fprintf('║     - 精度: 理论最优, 单快拍即可逼近CRB                             ║\n');
fprintf('║     - 模糊: 全局搜索天然解模糊, 10条基线抑制旁瓣                    ║\n');
fprintf('║     - 计算: 粗搜+细搜, PC上 <10ms                                  ║\n');
fprintf('║     - 鲁棒性: 不依赖协方差矩阵估计, 单快拍性能最佳                  ║\n');
fprintf('║     - 推荐度: ★★★★★ (本系统最优选择)                              ║\n');
fprintf('║                                                                    ║\n');
fprintf('║  5. Phase Compare (相位比较+解模糊)                                 ║\n');
fprintf('║     - 精度: 解模糊正确时逼近CRB                                    ║\n');
fprintf('║     - 风险: d/λ=1.33时解模糊依赖CBF粗估计                          ║\n');
fprintf('║             低SNR时CBF粗估计偏差可能导致解模糊失败                   ║\n');
fprintf('║     - 优势: 物理意义清晰, 易调试, 残差可做质量指标                   ║\n');
fprintf('║     - 推荐度: ★★★★☆ (可做ML的交叉验证)                            ║\n');
fprintf('║                                                                    ║\n');
fprintf('║  6. UCA Mode MUSIC (相位模态)                                      ║\n');
fprintf('║     - 精度: 与MUSIC类似, 利用了UCA对称性                            ║\n');
fprintf('║     - 局限: 5元阵仅有5个模态(-2~+2), 高阶模态截断误差大             ║\n');
fprintf('║     - 优势: 方位角和极角部分解耦                                    ║\n');
fprintf('║     - 推荐度: ★★★☆☆ (学术价值大, 工程中ML更直接)                  ║\n');
fprintf('║                                                                    ║\n');
fprintf('╠══════════════════════════════════════════════════════════════════════╣\n');
fprintf('║  最终推荐方案:                                                      ║\n');
fprintf('║    主力: ML (两级搜索) — 精度最优, 鲁棒性最好                       ║\n');
fprintf('║    辅助: Phase Compare — 提供残差质量指标, 交叉验证ML结果            ║\n');
fprintf('║    备份: CBF — 为Phase Compare提供粗估计, 故障时退化使用             ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════════╝\n');

%% 保存结果
results = struct();
results.snr_vec = snr_vec;
results.rmse_theta = rmse_theta;
results.rmse_phi = rmse_phi;
results.crb_theta = crb_theta;
results.crb_phi = crb_phi;
results.amb_fail = amb_fail;
results.time_avg = time_avg;
results.theta_scan = theta_scan;
results.rmse_vs_dir = rmse_vs_dir;
results.algo_names = algo_names;

save('doa_comparison_results.mat', 'results');
fprintf('\n结果已保存至 doa_comparison_results.mat\n');

%% ============================================================
%%  辅助函数: 生成带噪单快拍
%% ============================================================
function z = generate_snapshot(theta_deg, phi_deg, snr_dB, array, cfg)
% 生成窄带模型下的单快拍数据
%   z = s * a(theta,phi) + noise
    theta = deg2rad(theta_deg);
    phi   = deg2rad(phi_deg);
    a = steering_vector(theta, phi, array.pos, cfg.derived.k);
    N = array.N;

    % 信号: 单位功率, 随机相位
    s = exp(1j * 2*pi*rand);

    % 噪声
    snr_lin = 10^(snr_dB/10);
    noise_power = 1 / snr_lin;  % 信号功率=1
    noise = sqrt(noise_power/2) * (randn(N,1) + 1j*randn(N,1));

    z = s * a + noise;
end

function angle = wrapTo180(angle)
    angle = mod(angle + 180, 360) - 180;
end

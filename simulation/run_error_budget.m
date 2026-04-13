%% RUN_ERROR_BUDGET  系统级误差分配 + 灵敏度分析 主脚本
%
%  1. 运行误差分配分析: 各距离下各误差源贡献
%  2. 运行灵敏度分析: 各参数对性能的影响
%  3. 生成可视化图表
%
%  Author: USBL Algorithm Team
%  Date: 2026-03

clear; close all; clc;

%% 添加路径
addpath('config', 'core', 'doa', 'analysis');

%% 初始化
cfg = usbl_config();
array = create_uca5(cfg);

%% ===== Part 1: 误差分配分析 =====
eb_results = error_budget_analysis(cfg, array);

%% ===== Part 2: 灵敏度分析 =====
sa_results = sensitivity_analysis(cfg, array);

%% ===== Part 3: 可视化 =====

% 图1: 各距离下误差堆叠图
figure('Name', 'Error Budget', 'Position', [100 100 1000 600]);
ranges = eb_results.ranges;
sigma = eb_results.sigma;

% 各分量的方差占比 (堆叠面积图)
err_components = [sigma.range_total.^2, sigma.cross.^2, ...
                  sigma.ray.^2, sigma.gps.^2, sigma.motion.^2];
% 转为百分比
err_pct = bsxfun(@rdivide, err_components, sigma.total.^2) * 100;

subplot(2,2,1);
area(ranges/1000, err_pct);
xlabel('距离 (km)');
ylabel('误差贡献占比 (%)');
title('各误差源方差贡献占比');
legend('测距', '测角(横向)', '声线修正', 'GPS', '运动补偿', 'Location', 'best');
xlim([0.1, 10]);
grid on;

subplot(2,2,2);
semilogy(ranges/1000, sigma.total, 'b-o', 'LineWidth', 2, 'DisplayName', '总误差');
hold on;
semilogy(ranges/1000, ranges' * cfg.spec.position_accuracy, 'r--', 'LineWidth', 2, 'DisplayName', '1%限');
semilogy(ranges/1000, sigma.range_total, '-.', 'LineWidth', 1.2, 'DisplayName', '测距误差');
semilogy(ranges/1000, sigma.cross, '-.', 'LineWidth', 1.2, 'DisplayName', '横向误差');
hold off;
xlabel('距离 (km)');
ylabel('误差 (m)');
title('定位误差 vs 距离');
legend('Location', 'northwest');
grid on;

subplot(2,2,3);
plot(ranges/1000, sigma.pct, 'b-o', 'LineWidth', 2);
hold on;
yline(1.0, 'r--', '1% 指标', 'LineWidth', 2);
hold off;
xlabel('距离 (km)');
ylabel('定位误差 / 斜距 (%)');
title('相对定位精度');
grid on;
ylim([0, max(sigma.pct)*1.2]);

subplot(2,2,4);
% 10km处的误差饼图
ri_10km = find(ranges == 10000, 1);
if ~isempty(ri_10km)
    pie_data = [sigma.range_total(ri_10km)^2, sigma.cross(ri_10km)^2, ...
                sigma.ray(ri_10km)^2, sigma.gps(ri_10km)^2, sigma.motion(ri_10km)^2];
    pie_labels = {'测距', '测角(横向)', '声线修正', 'GPS', '运动补偿'};
    pie(pie_data, pie_labels);
    title(sprintf('10km处误差方差占比 (总误差=%.1fm, %.2f%%)', ...
        sigma.total(ri_10km), sigma.pct(ri_10km)));
end

sgtitle('USBL 系统级误差分配分析');

% 图2: CRB vs SNR
figure('Name', 'CRB Analysis', 'Position', [100 100 1000 600]);

subplot(2,2,1);
semilogy(sa_results.snr_scan.snr_vec, sa_results.snr_scan.crb_theta, 'b-', 'LineWidth', 2);
hold on;
yline(0.3, 'r--', '0.3° 预算', 'LineWidth', 1.5);
yline(0.57, 'g--', '0.57° (1%@任意距离)', 'LineWidth', 1.5);
hold off;
xlabel('SNR (dB, 后MF)');
ylabel('CRB(θ) (deg)');
title(sprintf('DOA CRB vs SNR (θ=%d°)', 30));
grid on;
ylim([0.01, 10]);

% 标注各距离对应的SNR
snr_post = eb_results.snr_post;
for ri = [2, 3, 5, 7, 8]  % 500m, 1km, 5km, 7km, 10km
    if ri <= length(ranges)
        xline(snr_post(ri), ':', sprintf('%dkm', ranges(ri)/1000), ...
            'LabelOrientation', 'horizontal', 'FontSize', 8);
    end
end

subplot(2,2,2);
plot(sa_results.theta_scan.theta_vec, sa_results.theta_scan.crb, '-', 'LineWidth', 1.5);
xlabel('目标极角 θ (deg)');
ylabel('CRB(θ) (deg)');
title(sprintf('CRB vs 目标方向 (SNR=%ddB)', sa_results.theta_scan.snr));
legend(arrayfun(@(x) sprintf('φ=%d°', x), sa_results.theta_scan.phi_vec, ...
    'UniformOutput', false), 'Location', 'best');
grid on;

subplot(2,2,3);
yyaxis left;
semilogy(sa_results.d_scan.d_over_lambda, sa_results.d_scan.crb, 'b-', 'LineWidth', 2);
ylabel('CRB(θ) (deg)');
yyaxis right;
plot(sa_results.d_scan.d_over_lambda, sa_results.d_scan.ambiguity_deg, 'r--', 'LineWidth', 1.5);
ylabel('模糊间距 (deg)');
xlabel('d/λ');
title('阵元间距权衡: 精度 vs 模糊');
xline(cfg.array.d_over_lambda, 'k:', sprintf('当前 d/λ=%.2f', cfg.array.d_over_lambda), ...
    'LineWidth', 1.5);
grid on;

subplot(2,2,4);
bar(sa_results.K_scan.K_vec, sa_results.K_scan.crb);
xlabel('快拍数 K');
ylabel('CRB(θ) (deg)');
title('多快拍积累效果');
set(gca, 'XScale', 'log');
grid on;

sgtitle('灵敏度分析');

%% 保存
save('error_budget_results.mat', 'eb_results', 'sa_results');
fprintf('\n结果已保存至 error_budget_results.mat\n');
fprintf('所有图表已生成完毕。\n');

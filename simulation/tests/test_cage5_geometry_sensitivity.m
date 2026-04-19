function test_cage5_geometry_sensitivity()
% TEST_CAGE5_GEOMETRY_SENSITIVITY 评估图纸推算坐标的不确定度对 DOA 精度的影响
%
% 动机：基于 2026-01-24 / 2026-04-15 两份供应商文档（机械图 + 电声测试报告），
% 可推算出 Z 坐标（±0.1 mm 精度，高置信）但径向 R 只能到 ±5-10 mm（低置信）。
% 本测试扫描 R_out 和方位角微扰，评估在"推算坐标"下 DOA 算法是否仍可用。
%
% 输出：RMSE vs R_out 曲线 + RMSE vs 方位角扰动曲线
%
% 解读：
% - 若 RMSE(R_out=75±5mm) 变化 > 0.3°，则必须向供应商要精确坐标
% - 若变化 < 0.3°，则推算坐标足够做初步仿真验证

    fprintf('\n========== test_cage5_geometry_sensitivity ==========\n');
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));

    cfg = usbl_config();
    cfg.array.type = 'CAGE5';
    k = cfg.derived.k;

    %% 基准几何（推算值）
    R_nominal = 0.075;    % 75 mm
    z_center  = 0.080;
    z_outer   = 0.110;

    theta_true = 30;
    phi_true   = 45;
    N_trial = 50;
    snr_dB = 10;

    %% --- Scan 1: R_out 扫描 ±10 mm ---
    R_scan = linspace(0.065, 0.085, 11);  % 65 ~ 85 mm
    rmse_R = zeros(length(R_scan), 1);

    for ri = 1:length(R_scan)
        R = R_scan(ri);
        cfg.array.cage_pos = [
            0,   0,  z_center;
            R,   0,  z_outer;
            0,   R,  z_outer;
           -R,   0,  z_outer;
            0,  -R,  z_outer];
        evalc('array = create_cage5(cfg);');

        err2 = zeros(N_trial, 1);
        for tr = 1:N_trial
            u = [sind(theta_true)*cosd(phi_true);
                 sind(theta_true)*sind(phi_true);
                 cosd(theta_true)];
            s = exp(1j * k * array.pos * u);
            noise_std = 10^(-snr_dB/20);
            z = s + noise_std * (randn(5,1) + 1j*randn(5,1)) / sqrt(2);
            [theta_est, phi_est] = doa_ml(z, array, cfg);
            err2(tr) = (theta_est - theta_true)^2 + ...
                       (mod(phi_est - phi_true + 180, 360) - 180)^2;
        end
        rmse_R(ri) = sqrt(mean(err2));
    end

    fprintf('\n--- R_out 敏感度（%.0f ~ %.0f mm，真 R=%.0f mm）---\n', ...
            R_scan(1)*1000, R_scan(end)*1000, R_nominal*1000);
    fprintf('R (mm) | RMSE (deg)\n');
    for ri = 1:length(R_scan)
        marker = ''; if abs(R_scan(ri)-R_nominal) < 1e-9, marker = '  <- nominal'; end
        fprintf('%6.0f | %8.3f%s\n', R_scan(ri)*1000, rmse_R(ri), marker);
    end

    % 判定
    rmse_ref = rmse_R(ceil(length(R_scan)/2));
    max_dev = max(abs(rmse_R - rmse_ref));
    fprintf('\n★ R_out ±10 mm 扰动下 RMSE 最大偏离 nominal：%.3f°\n', max_dev);
    if max_dev > 0.3
        fprintf('  ⚠️ 超过 0.3° 阈值 → 推算坐标不足以做精度分析，必须向供应商要精确坐标\n');
    else
        fprintf('  ✓ 未超 0.3° 阈值 → 推算坐标足够做初步仿真（但不可用于最终精度宣称）\n');
    end

    %% --- Scan 2: 方位角扰动 ---
    phi_bias_scan = -10:2:10;   % 方位偏移 -10° ~ +10°（如 4 立柱未精确对齐到 0°）
    rmse_phi = zeros(length(phi_bias_scan), 1);

    for bi = 1:length(phi_bias_scan)
        bias = deg2rad(phi_bias_scan(bi));
        angles = (0:3)' * pi/2 + bias;   % 4 外围 + 扰动
        R = R_nominal;
        cfg.array.cage_pos = [
            0, 0, z_center;
            R*cos(angles(1)), R*sin(angles(1)), z_outer;
            R*cos(angles(2)), R*sin(angles(2)), z_outer;
            R*cos(angles(3)), R*sin(angles(3)), z_outer;
            R*cos(angles(4)), R*sin(angles(4)), z_outer];
        evalc('array = create_cage5(cfg);');

        err2 = zeros(N_trial, 1);
        for tr = 1:N_trial
            u = [sind(theta_true)*cosd(phi_true);
                 sind(theta_true)*sind(phi_true);
                 cosd(theta_true)];
            s = exp(1j * k * array.pos * u);
            noise_std = 10^(-snr_dB/20);
            z = s + noise_std * (randn(5,1) + 1j*randn(5,1)) / sqrt(2);
            [theta_est, phi_est] = doa_ml(z, array, cfg);
            err2(tr) = (theta_est - theta_true)^2 + ...
                       (mod(phi_est - phi_true + 180, 360) - 180)^2;
        end
        rmse_phi(bi) = sqrt(mean(err2));
    end

    fprintf('\n--- 方位角扰动敏感度（四立柱方位对齐偏差）---\n');
    fprintf('偏移 (deg) | RMSE (deg)\n');
    for bi = 1:length(phi_bias_scan)
        fprintf('%+9.0f | %8.3f\n', phi_bias_scan(bi), rmse_phi(bi));
    end

    %% --- Scan 3: Z 坐标扰动（Z 本身 ±0.1 mm 精度高，但测试 ±1 mm 看敏感度）---
    dz_scan = -0.002:0.0005:0.002;  % Z_outer 扰动 ±2 mm
    rmse_z = zeros(length(dz_scan), 1);

    for zi = 1:length(dz_scan)
        dz = dz_scan(zi);
        R = R_nominal;
        cfg.array.cage_pos = [
            0,   0,  z_center;
            R,   0,  z_outer + dz;
            0,   R,  z_outer + dz;
           -R,   0,  z_outer + dz;
            0,  -R,  z_outer + dz];
        evalc('array = create_cage5(cfg);');

        err2 = zeros(N_trial, 1);
        for tr = 1:N_trial
            u = [sind(theta_true)*cosd(phi_true);
                 sind(theta_true)*sind(phi_true);
                 cosd(theta_true)];
            s = exp(1j * k * array.pos * u);
            noise_std = 10^(-snr_dB/20);
            z = s + noise_std * (randn(5,1) + 1j*randn(5,1)) / sqrt(2);
            [theta_est, phi_est] = doa_ml(z, array, cfg);
            err2(tr) = (theta_est - theta_true)^2 + ...
                       (mod(phi_est - phi_true + 180, 360) - 180)^2;
        end
        rmse_z(zi) = sqrt(mean(err2));
    end

    fprintf('\n--- Z 坐标扰动敏感度（Z_outer ±2 mm）---\n');
    fprintf('ΔZ (mm) | RMSE (deg)\n');
    for zi = 1:length(dz_scan)
        fprintf('%+7.1f | %8.3f\n', dz_scan(zi)*1000, rmse_z(zi));
    end

    fprintf('\n========== 敏感度分析完成 ==========\n\n');
end

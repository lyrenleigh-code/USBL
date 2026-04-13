function results = error_budget_analysis(cfg, array)
% ERROR_BUDGET_ANALYSIS USBL系统级误差分配分析
%
%   自顶向下将 "定位精度 ≤ 斜距的1%" 分配到各误差源
%   并分析各距离下的误差贡献占比
%
%   results = error_budget_analysis(cfg, array)
%
%   误差源分解:
%     1. 测距误差 (σ_R)
%        1a. 声速不确定性 → σ_R_sv
%        1b. 时延估计误差 → σ_R_toa (匹配滤波后极小)
%        1c. 应答器延迟不确定性 → σ_R_td
%     2. 测角误差 → 横向位置误差 (σ_cross = R × σ_angle)
%        2a. DOA算法估计误差 → σ_doa(SNR)
%        2b. 航向传感器误差 → σ_heading
%        2c. 横纵摇传感器误差 → σ_roll, σ_pitch
%        2d. 安装校准残差 → σ_cal
%     3. 声线弯曲残差 (修正后) → σ_ray
%     4. GPS/平台位置误差 → σ_gps
%     5. 平台运动补偿残差 → σ_motion
%
%   总误差: σ_total = sqrt(σ_R² + σ_cross² + σ_ray² + σ_gps² + σ_motion²)

    if nargin < 2
        array = create_uca5(cfg);
    end

    fprintf('\n');
    fprintf('╔══════════════════════════════════════════════════════════════╗\n');
    fprintf('║           USBL 系统级误差分配分析                           ║\n');
    fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');

    %% ===== 系统参数汇总 =====
    fprintf('【系统参数】\n');
    fprintf('  中心频率:     %.0f kHz\n', cfg.fc/1e3);
    fprintf('  波长:         %.1f cm\n', cfg.lambda*100);
    fprintf('  带宽:         %.0f kHz\n', cfg.signal.bw/1e3);
    fprintf('  信号时长:     %.0f ms\n', cfg.signal.duration*1e3);
    fprintf('  处理增益:     %.1f dB\n', cfg.signal.proc_gain_dB);
    fprintf('  阵元数:       %d\n', cfg.array.N_elements);
    fprintf('  阵元间距:     %.0f cm (d/λ = %.2f)\n', cfg.array.d*100, cfg.array.d_over_lambda);
    fprintf('  阵列孔径:     %.1f cm\n', cfg.array.aperture*100);
    fprintf('  精度指标:     斜距的 %.0f%%\n', cfg.spec.position_accuracy*100);
    fprintf('\n');

    %% ===== 各距离下 SNR 分析 =====
    ranges = [100, 500, 1000, 2000, 3000, 5000, 7000, 10000];
    N_R = length(ranges);

    fprintf('【各距离下信噪比分析】\n');
    fprintf('  %-8s  %-10s  %-14s  %-14s  %-10s\n', ...
        '距离(m)', 'TL(dB)', 'SNR预MF(dB)', 'SNR后MF(dB)', '1%限(m)');
    fprintf('  %s\n', repmat('-', 1, 60));

    snr_pre  = zeros(N_R, 1);
    snr_post = zeros(N_R, 1);
    TL_vec   = zeros(N_R, 1);

    for ri = 1:N_R
        R = ranges(ri);
        TL = cfg.prop.spreading * log10(R) + cfg.prop.alpha_dB_per_km * R/1000;
        TL_vec(ri) = TL;
        % 应答器模式(单程TL): SNR = SL_transponder - TL - NL - 10lg(BW) + DI
        snr_pre(ri) = cfg.transponder.SL - TL - cfg.rx.NL - 10*log10(cfg.signal.bw) + cfg.rx.DI;
        snr_post(ri) = snr_pre(ri) + cfg.signal.proc_gain_dB;

        fprintf('  %-8d  %-10.1f  %-14.1f  %-14.1f  %-10.1f\n', ...
            R, TL, snr_pre(ri), snr_post(ri), R * cfg.spec.position_accuracy);
    end
    fprintf('\n');

    %% ===== 各误差源分析 =====
    % 分析用的目标方向 (典型工况: 俯角30°)
    theta_test = 30;  % deg, 极角(相对阵法线)
    phi_test   = 45;  % deg, 方位角

    fprintf('【各误差源分析 (目标方向: θ=%.0f°, φ=%.0f°)】\n\n', theta_test, phi_test);

    % 预分配结果矩阵
    sigma = struct();
    sigma.range_sv    = zeros(N_R, 1);  % 声速不确定性引起的测距误差
    sigma.range_toa   = zeros(N_R, 1);  % 时延估计误差
    sigma.range_td    = zeros(N_R, 1);  % 应答器延迟误差
    sigma.range_total = zeros(N_R, 1);
    sigma.doa_theta   = zeros(N_R, 1);  % DOA估计误差(theta)
    sigma.doa_phi     = zeros(N_R, 1);  % DOA估计误差(phi)
    sigma.heading     = zeros(N_R, 1);  % 航向误差
    sigma.rollpitch   = zeros(N_R, 1);  % 横纵摇误差
    sigma.cal         = zeros(N_R, 1);  % 校准残差
    sigma.angle_total = zeros(N_R, 1);  % 总角度误差
    sigma.cross       = zeros(N_R, 1);  % 横向误差
    sigma.ray         = zeros(N_R, 1);  % 声线修正残差
    sigma.gps         = zeros(N_R, 1);  % GPS误差
    sigma.motion      = zeros(N_R, 1);  % 运动补偿残差
    sigma.total       = zeros(N_R, 1);  % 总误差
    sigma.pct         = zeros(N_R, 1);  % 总误差占斜距百分比

    for ri = 1:N_R
        R = ranges(ri);

        %% --- 1. 测距误差 ---
        % 1a. 声速不确定性: 假设声速知识精度 0.1% (经SVP修正后)
        sv_uncertainty_pct = 0.001;  % 0.1%
        sigma.range_sv(ri) = sv_uncertainty_pct * R;

        % 1b. 时延估计(匹配滤波后): σ_τ ≈ 1/(2π·BW·√(2·SNR))
        snr_lin = 10^(snr_post(ri)/10);
        if snr_lin > 0
            sigma_tau = 1 / (2*pi*cfg.signal.bw * sqrt(2*max(snr_lin, 1)));
        else
            sigma_tau = 1e-3;  % 默认1ms
        end
        sigma.range_toa(ri) = cfg.c * sigma_tau / 2;

        % 1c. 应答器延迟不确定性
        sigma.range_td(ri) = cfg.c * cfg.transponder.delay_std / 2;

        % 总测距误差 (RSS)
        sigma.range_total(ri) = sqrt(sigma.range_sv(ri)^2 + ...
                                     sigma.range_toa(ri)^2 + ...
                                     sigma.range_td(ri)^2);

        %% --- 2. 测角误差 ---
        % 2a. DOA估计CRB
        [crb_theta, crb_phi] = compute_doa_crb(theta_test, phi_test, ...
            snr_post(ri), array, cfg, 1);
        sigma.doa_theta(ri) = crb_theta;
        sigma.doa_phi(ri)   = crb_phi;

        % 2b. 航向传感器
        sigma.heading(ri) = cfg.sensor.heading_std_deg;

        % 2c. 横纵摇传感器 (对测角的影响 ≈ σ_roll/cos(theta))
        sigma.rollpitch(ri) = sqrt(cfg.sensor.roll_std_deg^2 + ...
                                   cfg.sensor.pitch_std_deg^2);

        % 2d. 校准残差
        sigma.cal(ri) = cfg.cal.cal_residual_std_deg;

        % 总角度误差 (RSS, 各分量独立)
        sigma.angle_total(ri) = sqrt(sigma.doa_theta(ri)^2 + ...
                                     sigma.heading(ri)^2 + ...
                                     sigma.rollpitch(ri)^2 + ...
                                     sigma.cal(ri)^2);

        % 横向位置误差 = R × σ_angle (rad)
        sigma.cross(ri) = R * deg2rad(sigma.angle_total(ri));

        %% --- 3. 声线修正残差 ---
        % 假设SVP修正后残差 = 距离的 0.02% (经验值)
        ray_residual_pct = 0.0002;
        sigma.ray(ri) = ray_residual_pct * R;

        %% --- 4. GPS位置误差 ---
        sigma.gps(ri) = cfg.sensor.gps_std_m;

        %% --- 5. 运动补偿残差 ---
        % 假设平台速度2m/s, IMU推算精度1%, 双程时间内
        v_platform = 2;  % m/s
        imu_pct_error = 0.01;
        round_trip_time = 2*R / cfg.c + cfg.transponder.delay;
        motion_during_trip = v_platform * round_trip_time;
        sigma.motion(ri) = motion_during_trip * imu_pct_error;

        %% --- 总定位误差 ---
        sigma.total(ri) = sqrt(sigma.range_total(ri)^2 + ...
                               sigma.cross(ri)^2 + ...
                               sigma.ray(ri)^2 + ...
                               sigma.gps(ri)^2 + ...
                               sigma.motion(ri)^2);
        sigma.pct(ri) = sigma.total(ri) / R * 100;
    end

    %% ===== 打印结果表格 =====
    fprintf('┌──────────────────────────────────────────────────────────────────────┐\n');
    fprintf('│                      各距离下误差预算表 (单位: m)                      │\n');
    fprintf('├────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┤\n');
    fprintf('│ 距离   │测距误差│横向误差│声线残差│GPS误差 │运动补偿│ 总误差 │占斜距%% │\n');
    fprintf('├────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┤\n');
    for ri = 1:N_R
        fprintf('│%6dm │%6.2fm │%6.2fm │%6.2fm │%6.2fm │%6.2fm │%6.1fm │%6.2f%% │\n', ...
            ranges(ri), sigma.range_total(ri), sigma.cross(ri), ...
            sigma.ray(ri), sigma.gps(ri), sigma.motion(ri), ...
            sigma.total(ri), sigma.pct(ri));
    end
    fprintf('└────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┘\n\n');

    %% ===== 角度误差分解表 =====
    fprintf('┌──────────────────────────────────────────────────────────────────────┐\n');
    fprintf('│                    角度误差分解表 (单位: deg)                          │\n');
    fprintf('├────────┬─────────┬─────────┬─────────┬─────────┬─────────┬───────────┤\n');
    fprintf('│ 距离   │DOA(CRB) │ 航向    │横纵摇   │校准残差  │ 总角度  │后MF SNR   │\n');
    fprintf('├────────┼─────────┼─────────┼─────────┼─────────┼─────────┼───────────┤\n');
    for ri = 1:N_R
        fprintf('│%6dm │ %6.3f° │ %6.3f° │ %6.3f° │ %6.3f° │ %6.3f° │ %5.1f dB  │\n', ...
            ranges(ri), sigma.doa_theta(ri), sigma.heading(ri), ...
            sigma.rollpitch(ri), sigma.cal(ri), sigma.angle_total(ri), ...
            snr_post(ri));
    end
    fprintf('└────────┴─────────┴─────────┴─────────┴─────────┴─────────┴───────────┘\n\n');

    %% ===== 关键结论 =====
    fprintf('【关键结论】\n');

    % 找到满足1%精度的最大距离
    idx_pass = find(sigma.pct <= 1.0);
    if ~isempty(idx_pass)
        max_range_1pct = ranges(idx_pass(end));
        fprintf('  ✓ 满足1%%精度指标的最大距离: %d m\n', max_range_1pct);
    else
        fprintf('  ✗ 在所有测试距离下均不满足1%%精度指标\n');
    end

    % 识别主导误差源
    for ri = [find(ranges==1000,1), find(ranges==5000,1), find(ranges==10000,1)]
        if isempty(ri), continue; end
        errors = [sigma.range_total(ri), sigma.cross(ri), sigma.ray(ri), ...
                  sigma.gps(ri), sigma.motion(ri)];
        names = {'测距', '横向(测角)', '声线修正', 'GPS', '运动补偿'};
        [~, dom_idx] = max(errors);
        pct_dom = errors(dom_idx)^2 / sigma.total(ri)^2 * 100;
        fprintf('  @ %5dm: 主导误差源 = %s (贡献 %.0f%%)\n', ...
            ranges(ri), names{dom_idx}, pct_dom);
    end

    % DOA精度对总精度的敏感度
    fprintf('\n【DOA精度灵敏度分析 (10km处)】\n');
    ri_10km = find(ranges==10000, 1);
    if ~isempty(ri_10km)
        doa_test = [0.1, 0.2, 0.3, 0.5, 0.7, 1.0];
        for di = 1:length(doa_test)
            sigma_a = sqrt(doa_test(di)^2 + sigma.heading(ri_10km)^2 + ...
                          sigma.rollpitch(ri_10km)^2 + sigma.cal(ri_10km)^2);
            sigma_c = 10000 * deg2rad(sigma_a);
            sigma_t = sqrt(sigma.range_total(ri_10km)^2 + sigma_c^2 + ...
                          sigma.ray(ri_10km)^2 + sigma.gps(ri_10km)^2 + ...
                          sigma.motion(ri_10km)^2);
            fprintf('  DOA精度 = %.1f° → 总误差 = %.1fm (%.2f%%)\n', ...
                doa_test(di), sigma_t, sigma_t/10000*100);
        end
    end

    %% ===== 误差分配建议 =====
    fprintf('\n【误差分配建议 (目标: 10km处 ≤ 1%%)】\n');
    fprintf('  ┌───────────────────┬─────────────┬──────────────────────────────┐\n');
    fprintf('  │ 误差源            │ 分配预算     │ 实现途径                      │\n');
    fprintf('  ├───────────────────┼─────────────┼──────────────────────────────┤\n');
    fprintf('  │ DOA估计           │ ≤ 0.30°     │ ML算法 + 高SNR信号设计        │\n');
    fprintf('  │ 航向传感器        │ ≤ 0.10°     │ 光纤陀螺罗经                  │\n');
    fprintf('  │ 横纵摇传感器      │ ≤ 0.03°     │ 惯导姿态传感器                │\n');
    fprintf('  │ 安装校准残差      │ ≤ 0.05°     │ 走圆校准 + 在线估计           │\n');
    fprintf('  │ 声速知识精度      │ ≤ 0.1%%     │ 实时SVP输入 + 射线追踪        │\n');
    fprintf('  │ 应答器延迟精度    │ ≤ 50μs      │ 出厂标定                     │\n');
    fprintf('  │ GPS位置           │ ≤ 2m        │ 差分GPS可到0.3m              │\n');
    fprintf('  │ 运动补偿          │ ≤ 0.3m      │ IMU推算精度 + 时间同步        │\n');
    fprintf('  └───────────────────┴─────────────┴──────────────────────────────┘\n');

    %% 保存结果
    results.ranges   = ranges;
    results.snr_pre  = snr_pre;
    results.snr_post = snr_post;
    results.TL       = TL_vec;
    results.sigma    = sigma;
end

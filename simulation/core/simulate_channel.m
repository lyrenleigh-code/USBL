function [x_rx, info] = simulate_channel(s_tx, cfg, array, target)
% SIMULATE_CHANNEL 仿真水声信道，生成各阵元接收信号
%
%   [x_rx, info] = simulate_channel(s_tx, cfg, array, target)
%
%   输入:
%     s_tx   - 1xM 发射信号
%     cfg    - 系统参数
%     array  - 阵列结构体 (由 create_uca5 生成)
%     target - 目标参数结构体
%              .range     - 斜距 (m)
%              .theta_deg - 极角 (deg), 0=正下方
%              .phi_deg   - 方位角 (deg), 0=前方
%              .snr_dB    - (可选) 指定信噪比, 不指定则由声纳方程计算
%
%   输出:
%     x_rx - 5xL 各阵元接收信号 (含噪声)
%     info - 仿真信息结构体

    fs = cfg.signal.fs;
    N_ch = array.N;
    M = length(s_tx);

    theta = deg2rad(target.theta_deg);
    phi   = deg2rad(target.phi_deg);
    R     = target.range;

    %% 传播损失计算
    TL = cfg.prop.spreading * log10(R) + cfg.prop.alpha_dB_per_km * R/1000;

    %% 信噪比计算
    if isfield(target, 'snr_dB') && ~isempty(target.snr_dB)
        snr_dB = target.snr_dB;
    else
        % 应答器模式链路预算 (单程TL):
        %   平台接收应答器回复信号 → SNR = SL_transponder - TL - NL - 10lg(BW) + DI
        snr_dB = cfg.transponder.SL - TL + cfg.rx.DI - cfg.rx.NL - 10*log10(cfg.signal.bw);
    end
    info.snr_pre_mf_dB = snr_dB;
    info.snr_post_mf_dB = snr_dB + cfg.signal.proc_gain_dB;
    info.TL = TL;

    %% 各阵元相对延迟 (远场平面波模型)
    u = [sin(theta)*cos(phi); sin(theta)*sin(phi); cos(theta)];
    tau_diff = array.pos * u / cfg.c;  % Nx1, 各阵元相对于阵心的时延差 (s)
    tau_diff_samples = tau_diff * fs;   % 转换为采样点数

    %% 传播总延迟 (阵心到目标)
    tau_prop = R / cfg.c;
    info.tau_prop = tau_prop;
    info.tau_diff = tau_diff;

    %% 生成各通道接收信号
    % 方法: 在频域做精确分数延迟
    N_fft = 2^nextpow2(M + ceil(max(abs(tau_diff_samples))) + 100);
    S_tx = fft(s_tx, N_fft);
    freq = (0:N_fft-1) / N_fft * fs;

    % 信号幅度衰减
    amp = 10^(-TL/20);

    x_signal = zeros(N_ch, N_fft);
    for ch = 1:N_ch
        % 频域延迟: 乘以 exp(-j*2*pi*f*tau)
        delay_phase = exp(-1j * 2 * pi * freq * tau_diff(ch));
        X_delayed = S_tx .* delay_phase;
        x_signal(ch,:) = amp * real(ifft(X_delayed));
    end

    %% 添加噪声
    snr_linear = 10^(snr_dB / 10);
    signal_power = amp^2 * mean(abs(s_tx).^2);
    noise_power = signal_power / snr_linear;

    noise = sqrt(noise_power/2) * (randn(N_ch, N_fft) + 1j*randn(N_ch, N_fft));
    noise = real(noise);  % 实信号

    x_rx = x_signal + noise;

    % 截取有效长度
    L_out = M + ceil(max(abs(tau_diff_samples))) + 100;
    x_rx = x_rx(:, 1:min(L_out, N_fft));

    info.signal_power = signal_power;
    info.noise_power  = noise_power;
    info.N_fft        = N_fft;
end

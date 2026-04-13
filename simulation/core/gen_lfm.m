function [s, t] = gen_lfm(cfg)
% GEN_LFM 生成线性调频(LFM/Chirp)信号
%
%   [s, t] = gen_lfm(cfg)
%
%   输入:
%     cfg - 系统参数结构体
%
%   输出:
%     s - 1xN 复基带LFM信号
%     t - 1xN 时间向量 (s)

    fs  = cfg.signal.fs;
    T   = cfg.signal.duration;
    BW  = cfg.signal.bw;
    fc  = cfg.fc;

    t = (0 : 1/fs : T - 1/fs);
    N = length(t);

    % 调频斜率
    k_chirp = BW / T;

    % 生成实带通 LFM 信号
    % s(t) = exp(j*2*pi*(fc*t + 0.5*k*t^2))
    % 频率从 fc - BW/2 线性扫到 fc + BW/2
    phase = 2*pi * (fc - BW/2) * t + pi * k_chirp * t.^2;
    s = exp(1j * phase);

    % 归一化能量
    s = s / sqrt(N);
end

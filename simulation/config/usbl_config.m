function cfg = usbl_config()
% USBL_CONFIG 超短基线定位系统参数配置
%   cfg = usbl_config() 返回系统全部参数的结构体
%
%   使用方法：cfg = usbl_config(); 然后通过 cfg.xxx 访问各参数

    %% ===== 声学参数 =====
    cfg.fc     = 10e3;          % 中心频率 (Hz)
    cfg.c      = 1500;          % 参考声速 (m/s)
    cfg.lambda = cfg.c/cfg.fc;  % 波长 (m) = 0.15m

    %% ===== 信号参数 =====
    cfg.signal.type     = 'LFM';      % 信号类型
    cfg.signal.bw       = 4e3;        % 带宽 (Hz): 8kHz ~ 12kHz
    cfg.signal.duration = 0.1;        % 信号时长 (s)
    cfg.signal.fs       = 48e3;       % 采样率 (Hz)
    cfg.signal.f_low    = cfg.fc - cfg.signal.bw/2;  % 下限频率
    cfg.signal.f_high   = cfg.fc + cfg.signal.bw/2;  % 上限频率
    cfg.signal.TBP      = cfg.signal.bw * cfg.signal.duration;  % 时间带宽积
    cfg.signal.proc_gain_dB = 10*log10(cfg.signal.TBP);         % 匹配滤波处理增益 (dB)

    %% ===== 阵列参数 =====
    cfg.array.N_elements = 5;         % 阵元数
    cfg.array.d          = 0.20;      % 相邻阵元间距 (m)
    cfg.array.type       = 'UCA5';    % 五元均匀圆阵
    % 外接圆半径
    cfg.array.R_a = cfg.array.d / (2*sin(pi/cfg.array.N_elements));
    % d/lambda 比值 → 判断相位模糊
    cfg.array.d_over_lambda = cfg.array.d / cfg.lambda;
    % 阵列孔径
    cfg.array.aperture = 2 * cfg.array.R_a;
    % 短基线模糊间距 (deg)
    cfg.array.ambiguity_short_deg = asind(cfg.lambda / cfg.array.d);
    % 波束宽度近似 (deg)
    cfg.array.beamwidth_deg = rad2deg(cfg.lambda / cfg.array.aperture);

    %% ===== 换能器/发射参数 =====
    cfg.tx.SL = 190;    % 平台发射声源级 (dB re 1uPa @ 1m)
    cfg.tx.DI = 0;      % 发射指向性指数 (dB), 全向

    %% ===== 应答器参数(声学) =====
    cfg.transponder.SL = 185;   % 应答器回复声源级 (dB re 1uPa @ 1m)

    %% ===== 接收参数 =====
    cfg.rx.NL = 60;     % 环境噪声级 (dB re 1uPa/sqrt(Hz)), 典型海况3级
    cfg.rx.DI = 0;      % 单阵元接收指向性指数

    %% ===== 作用距离参数 =====
    cfg.range.max    = 10000;   % 最大作用距离 (m)
    cfg.range.min    = 100;     % 最小作用距离 (m)
    cfg.range.test   = [500, 1000, 2000, 5000, 7000, 10000]; % 测试距离点

    %% ===== 精度指标 =====
    cfg.spec.range_accuracy  = 0.01;   % 斜距精度: 1%
    cfg.spec.position_accuracy = 0.01; % 定位精度: 斜距的1%

    %% ===== 传播损失模型 (Thorp吸收 + 球面扩展) =====
    % 10 kHz 吸收系数 (Thorp公式简化)
    f_kHz = cfg.fc / 1e3;
    cfg.prop.alpha_dB_per_km = 0.11 * f_kHz^2 / (1 + f_kHz^2) + ...
                                44 * f_kHz^2 / (4100 + f_kHz^2) + ...
                                2.75e-4 * f_kHz^2 + 0.003;
    cfg.prop.spreading = 20;  % 球面扩展系数 (20lgR)

    %% ===== 声速剖面 (典型深海) =====
    % [深度(m), 声速(m/s)]
    cfg.svp = [
        0,    1520;
        20,   1518;
        50,   1515;
        100,  1510;
        200,  1500;
        500,  1485;
        800,  1480;
        1000, 1482;
        1500, 1490;
        2000, 1500;
        3000, 1515;
        4000, 1535;
    ];

    %% ===== 姿态传感器精度 =====
    cfg.sensor.heading_std_deg  = 0.10;   % 航向精度 (deg), 光纤罗经
    cfg.sensor.roll_std_deg     = 0.02;   % 横摇精度 (deg)
    cfg.sensor.pitch_std_deg    = 0.02;   % 纵摇精度 (deg)
    cfg.sensor.depth_std_m      = 0.1;    % 深度精度 (m)
    cfg.sensor.gps_std_m        = 2.0;    % GPS 位置精度 (m), 普通GPS
    cfg.sensor.dgps_std_m       = 0.3;    % DGPS 位置精度 (m)

    %% ===== 安装校准参数 =====
    cfg.cal.install_roll_true_deg  = 0.5;   % 真实安装横摇偏差 (仿真用)
    cfg.cal.install_pitch_true_deg = -0.3;  % 真实安装纵摇偏差
    cfg.cal.install_yaw_true_deg   = 1.2;   % 真实安装艏向偏差
    cfg.cal.cal_residual_std_deg   = 0.05;  % 校准后残余偏差标准差

    %% ===== 应答器参数 =====
    cfg.transponder.delay    = 5e-3;        % 应答器固有延迟 (s)
    cfg.transponder.delay_std = 50e-6;      % 延迟不确定性 (s)

    %% ===== 仿真控制参数 =====
    cfg.sim.N_monte_carlo = 500;     % 蒙特卡洛仿真次数
    cfg.sim.snr_range_dB  = -10:2:30; % SNR扫描范围 (dB)
    cfg.sim.doa_grid_coarse = 2;     % 粗搜索网格间距 (deg)
    cfg.sim.doa_grid_fine   = 0.1;   % 细搜索网格间距 (deg)

    %% ===== 计算衍生参数 =====
    cfg.derived.k = 2*pi*cfg.fc / cfg.c;   % 波数
    cfg.derived.T_round_trip_max = 2*cfg.range.max / cfg.c; % 最大双程传播时间
    cfg.derived.update_rate_min = 1 / (cfg.derived.T_round_trip_max + ...
                                       cfg.transponder.delay + cfg.signal.duration);
end

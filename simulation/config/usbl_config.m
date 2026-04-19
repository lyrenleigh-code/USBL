function cfg = usbl_config()
% USBL_CONFIG 超短基线定位系统参数配置
%   cfg = usbl_config() 返回系统全部参数的结构体
%
%   使用方法：cfg = usbl_config(); 然后通过 cfg.xxx 访问各参数

    %% ===== 声学参数 =====
    % 2026-04-19: fc 从 10 kHz 更新为 12 kHz
    % 依据：供应商 NeUB-816 样机测试报告（江苏水声技术，2026-01-24），
    % 9 项电声测试均在 12 kHz 频点，包括水平/垂直指向性、幅度/相位一致性。
    % 详见 wiki/source-summaries/neub-816-test-report-260102.md
    cfg.fc     = 12e3;          % 中心频率 (Hz)
    cfg.c      = 1500;          % 参考声速 (m/s)
    cfg.lambda = cfg.c/cfg.fc;  % 波长 (m) ≈ 0.125 m

    %% ===== 信号参数 =====
    cfg.signal.type     = 'LFM';      % 信号类型
    cfg.signal.bw       = 4e3;        % 带宽 (Hz): 10kHz ~ 14kHz（围绕新 fc）
    cfg.signal.duration = 0.1;        % 信号时长 (s)
    cfg.signal.fs       = 48e3;       % 采样率 (Hz)
    cfg.signal.f_low    = cfg.fc - cfg.signal.bw/2;  % 下限频率
    cfg.signal.f_high   = cfg.fc + cfg.signal.bw/2;  % 上限频率
    cfg.signal.TBP      = cfg.signal.bw * cfg.signal.duration;  % 时间带宽积
    cfg.signal.proc_gain_dB = 10*log10(cfg.signal.TBP);         % 匹配滤波处理增益 (dB)

    %% ===== 阵列参数 =====
    % 2026-04-19: type 从 'UCA5' 更新为 'CAGE5'
    % 依据：工程图（2026-04-15）3D 视图 + 测试报告（2026-01-24）垂直指向性
    % 非对称（180° 方向凹陷），两独立来源共同佐证笼式立体阵结构。
    % 精确 5 阵元坐标待供应商 STEP/IGES 模型到手后通过 cfg.array.cage_pos 填入。
    cfg.array.N_elements = 5;         % 阵元数
    cfg.array.type       = 'CAGE5';   % 阵型: 'UCA5' (平面圆阵) | 'CAGE5' (笼式立体阵)

    switch upper(cfg.array.type)
        case 'UCA5'
            % 平面五元均匀圆阵
            cfg.array.d          = 0.20;                                     % 相邻阵元间距 (m)
            cfg.array.R_a        = cfg.array.d / (2*sin(pi/cfg.array.N_elements));
            cfg.array.d_over_lambda = cfg.array.d / cfg.lambda;
            cfg.array.aperture   = 2 * cfg.array.R_a;
            cfg.array.ambiguity_short_deg = asind(cfg.lambda / cfg.array.d);
            cfg.array.beamwidth_deg = rad2deg(cfg.lambda / cfg.array.aperture);

        case 'CAGE5'
            % 笼式立体阵（供应商方案，见 wiki/source-summaries/
            % five-element-transducer-assembly-drawing-vA.md 及
            % wiki/source-summaries/neub-816-test-report-260102.md）
            %
            % === 标称坐标（nominal design coordinates）===
            % 依据：
            %   - 工程图直接标注：水听器中心 Z = 80 ±0.10 mm（中央）
            %                      水听器中心 Z = 110 ±0.10 mm（外围 4 元）
            %   - 径向推算：外围立柱在 Φ160 法兰圆 / 2 = 75 mm 半径（65-85 mm 合理范围的中值）
            %   - 方位角：假设 4 外围均布于 0°/90°/180°/270°（水平指向性近全向支持此假设）
            %
            % 假设：假定实际制造无误差（2026-04-19 决策），阵列几何 = 设计几何。
            % 实际加工残差后续由 M2 电声一致性标定 + 在线重构（M4）补偿。
            cfg.array.cage_pos = [
                 0.000,   0.000,   0.080;   % 通道 1：中央水听器（轴心）
                 0.075,   0.000,   0.110;   % 通道 2：外围 0°  (+x)
                 0.000,   0.075,   0.110;   % 通道 3：外围 90° (+y)
                -0.075,   0.000,   0.110;   % 通道 4：外围 180°(-x)
                 0.000,  -0.075,   0.110;   % 通道 5：外围 270°(-y)
            ];
            % 保留以下三项，便于 create_cage5 用户显式覆盖默认占位
            cfg.array.cage_z_center     = cfg.array.cage_pos(1, 3);   % 0.080
            cfg.array.cage_z_outer      = cfg.array.cage_pos(2, 3);   % 0.110
            cfg.array.cage_radius_outer = norm(cfg.array.cage_pos(2, 1:2));  % 0.075
            % d_over_lambda 用"最小基线"近似：中央到外围的 3D 距离
            d_min = norm(cfg.array.cage_pos(2, :) - cfg.array.cage_pos(1, :));
            cfg.array.d = d_min;
            cfg.array.d_over_lambda = d_min / cfg.lambda;

        otherwise
            error('usbl_config: 不支持的阵型 "%s"，当前支持 UCA5 / CAGE5', ...
                  cfg.array.type);
    end

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
    % 吸收系数由 cfg.fc 自动计算（Thorp 公式简化），与中心频率一致
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

    %% ===== 安装校准参数 (M3) =====
    cfg.cal.install_roll_true_deg  = 0.5;   % 真实安装横摇偏差 (仿真用)
    cfg.cal.install_pitch_true_deg = -0.3;  % 真实安装纵摇偏差
    cfg.cal.install_yaw_true_deg   = 1.2;   % 真实安装艏向偏差
    cfg.cal.cal_residual_std_deg   = 0.05;  % 校准后残余偏差标准差

    %% ===== 阵列标定精度 (M1 阵列几何 / M2 电声一致性) =====
    cfg.cal.geometry_pos_std_m   = 0.5e-3;  % M1: 阵元位置标定不确定度 (m), 目标<0.5mm
    cfg.cal.phase_residual_deg   = 1.0;     % M2: 校正后通道间相位残差 (deg)
    cfg.cal.amp_residual_dB      = 0.3;     % M2: 校正后通道间幅度残差 (dB)

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

function test_cage5_geometry()
% TEST_CAGE5_GEOMETRY 笼式五元立体阵几何 + DOA 算法端到端回归测试
%
%   覆盖：
%     1. create_cage5 默认占位几何：基本字段齐全 + is_planar=false
%     2. create_cage5 用户显式坐标：pos 按输入填入
%     3. create_array dispatcher：按 type 正确分发
%     4. doa_phase_compare 在立体阵下走 3D LS 分支，能恢复已知 DOA
%     5. doa_uca_mode_music 在立体阵下正确报错
%     6. doa_ml 在立体阵下不改代码即可工作（通过 steering_vector 通用性）
%
%   运行方式：
%     cd D:/Claude/TechReq/USBL/simulation
%     addpath(genpath('.'));
%     run('tests/test_cage5_geometry.m');

    fprintf('\n========== test_cage5_geometry ==========\n');
    addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));

    n_pass = 0;
    n_fail = 0;

    %% --- Test 1: create_cage5 占位默认几何 ---
    try
        cfg = usbl_config();
        cfg.array.type = 'CAGE5';
        cfg.array.cage_z_center = 0.080;
        cfg.array.cage_z_outer  = 0.110;
        cfg.array.cage_radius_outer = 0.065;
        evalc('array = create_cage5(cfg);');  % 静默 fprintf

        assert(isequal(size(array.pos), [5, 3]), 'pos size 错');
        assert(array.N == 5, 'N 错');
        assert(strcmpi(array.type, 'CAGE5'), 'type 错');
        assert(array.is_planar == false, 'is_planar 应为 false');
        assert(isfield(array, 'baselines'), '缺 baselines 字段');
        assert(size(array.baselines.pairs, 1) == 10, 'baselines 对数错（C(5,2)=10）');
        % 中央水听器在原点附近
        assert(norm(array.pos(1, 1:2)) < 1e-6, '中央水听器 xy 应为 (0,0)');
        assert(abs(array.pos(1, 3) - 0.080) < 1e-6, '中央水听器 z 应为 0.080');
        fprintf('  ✓ T1 占位默认几何\n');
        n_pass = n_pass + 1;
    catch e
        fprintf('  ✗ T1 失败: %s\n', e.message);
        n_fail = n_fail + 1;
    end

    %% --- Test 2: create_cage5 用户显式坐标 ---
    try
        cfg = usbl_config();
        cfg.array.type = 'CAGE5';
        explicit_pos = [
            0,      0,     0.050;
            0.070,  0,     0.120;
            0,      0.070, 0.120;
           -0.070,  0,     0.120;
            0,     -0.070, 0.120;
        ];
        cfg.array.cage_pos = explicit_pos;
        evalc('array = create_cage5(cfg);');

        assert(isequal(array.pos, explicit_pos), 'pos 未按输入填入');
        assert(~array.is_planar, 'is_planar 应为 false');
        fprintf('  ✓ T2 用户显式坐标\n');
        n_pass = n_pass + 1;
    catch e
        fprintf('  ✗ T2 失败: %s\n', e.message);
        n_fail = n_fail + 1;
    end

    %% --- Test 3: create_array dispatcher ---
    try
        % 构造 UCA5 配置（usbl_config 默认 CAGE5，此处手工切换 + 补 UCA 专用字段）
        cfg_uca = usbl_config();
        cfg_uca.array.type  = 'UCA5';
        cfg_uca.array.d     = 0.20;
        cfg_uca.array.R_a   = cfg_uca.array.d / (2*sin(pi/cfg_uca.array.N_elements));
        cfg_uca.array.aperture            = 2 * cfg_uca.array.R_a;
        cfg_uca.array.ambiguity_short_deg = asind(cfg_uca.lambda / cfg_uca.array.d);
        cfg_uca.array.beamwidth_deg       = rad2deg(cfg_uca.lambda / cfg_uca.array.aperture);
        cfg_uca.array.d_over_lambda       = cfg_uca.array.d / cfg_uca.lambda;
        evalc('a1 = create_array(cfg_uca);');
        assert(strcmpi(a1.type, 'UCA5'));
        assert(a1.is_planar == true);

        % CAGE5 使用 usbl_config 默认（已含标称 cage_pos 坐标）
        cfg_cage = usbl_config();
        evalc('a2 = create_array(cfg_cage);');
        assert(strcmpi(a2.type, 'CAGE5'));
        assert(a2.is_planar == false);

        % 不支持的 type 应报错
        cfg_bad = cfg_uca;
        cfg_bad.array.type = 'UNKNOWN';
        err = false;
        try
            create_array(cfg_bad);
        catch
            err = true;
        end
        assert(err, 'UNKNOWN 类型应报错');
        fprintf('  ✓ T3 dispatcher\n');
        n_pass = n_pass + 1;
    catch e
        fprintf('  ✗ T3 失败: %s\n', e.message);
        n_fail = n_fail + 1;
    end

    %% --- Test 4: doa_phase_compare 在立体阵下 3D LS 分支 ---
    try
        cfg = usbl_config();
        cfg.array.type = 'CAGE5';
        cfg.array.cage_z_center = 0.080;
        cfg.array.cage_z_outer = 0.110;
        cfg.array.cage_radius_outer = 0.065;
        evalc('array = create_array(cfg);');

        % 构造已知 DOA 的理想信号（无噪声）
        theta_true = 30;   % deg
        phi_true   = 60;   % deg
        k = cfg.derived.k;
        u_true = [sind(theta_true)*cosd(phi_true);
                  sind(theta_true)*sind(phi_true);
                  cosd(theta_true)];
        z = exp(1j * k * array.pos * u_true);   % 5x1 理想接收

        % 相位比较法（带正确粗估初值）
        [theta_est, phi_est, info] = doa_phase_compare(z, array, cfg, theta_true, phi_true);

        err_theta = abs(theta_est - theta_true);
        err_phi   = abs(mod(phi_est - phi_true + 180, 360) - 180);
        assert(err_theta < 0.5, sprintf('theta 误差过大：est=%.3f vs true=%.3f', theta_est, theta_true));
        assert(err_phi < 0.5,   sprintf('phi 误差过大：est=%.3f vs true=%.3f', phi_est, phi_true));
        assert(info.residual_rms < 0.01, sprintf('残差 rms 过大：%.4f rad', info.residual_rms));
        fprintf('  ✓ T4 phase_compare 立体阵 3D LS（theta 误差 %.3f° / phi 误差 %.3f° / rms %.4f rad）\n', ...
                err_theta, err_phi, info.residual_rms);
        n_pass = n_pass + 1;
    catch e
        fprintf('  ✗ T4 失败: %s\n', e.message);
        n_fail = n_fail + 1;
    end

    %% --- Test 5: doa_uca_mode_music 在立体阵下正确报错 ---
    try
        cfg = usbl_config();
        cfg.array.type = 'CAGE5';
        cfg.array.cage_z_center = 0.080;
        cfg.array.cage_z_outer = 0.110;
        cfg.array.cage_radius_outer = 0.065;
        evalc('array = create_array(cfg);');

        z = ones(5, 1);
        err = false;
        try
            doa_uca_mode_music(z, array, cfg);
        catch ME
            err = true;
            assert(contains(ME.message, 'UCA') || contains(ME.message, 'planar'), ...
                   '报错消息应提及 UCA 或 planar');
        end
        assert(err, 'doa_uca_mode_music 应对 CAGE5 报错');
        fprintf('  ✓ T5 uca_mode_music 拒绝立体阵\n');
        n_pass = n_pass + 1;
    catch e
        fprintf('  ✗ T5 失败: %s\n', e.message);
        n_fail = n_fail + 1;
    end

    %% --- Test 6: doa_ml 在立体阵下无需修改即可工作 ---
    try
        cfg = usbl_config();
        cfg.array.type = 'CAGE5';
        cfg.array.cage_z_center = 0.080;
        cfg.array.cage_z_outer = 0.110;
        cfg.array.cage_radius_outer = 0.065;
        evalc('array = create_array(cfg);');

        theta_true = 25;
        phi_true   = 135;
        k = cfg.derived.k;
        u_true = [sind(theta_true)*cosd(phi_true);
                  sind(theta_true)*sind(phi_true);
                  cosd(theta_true)];
        z = exp(1j * k * array.pos * u_true);

        [theta_est, phi_est] = doa_ml(z, array, cfg);

        err_theta = abs(theta_est - theta_true);
        err_phi   = abs(mod(phi_est - phi_true + 180, 360) - 180);
        assert(err_theta < 0.2, sprintf('ML theta 误差过大：%.3f°', err_theta));
        assert(err_phi < 0.2,   sprintf('ML phi 误差过大：%.3f°', err_phi));
        fprintf('  ✓ T6 doa_ml 立体阵无代码修改（theta 误差 %.3f° / phi 误差 %.3f°）\n', ...
                err_theta, err_phi);
        n_pass = n_pass + 1;
    catch e
        fprintf('  ✗ T6 失败: %s\n', e.message);
        n_fail = n_fail + 1;
    end

    %% --- 汇总 ---
    fprintf('\n========== 结果：%d 通过 / %d 失败 ==========\n\n', n_pass, n_fail);
    if n_fail > 0
        error('test_cage5_geometry: %d 项测试失败', n_fail);
    end
end

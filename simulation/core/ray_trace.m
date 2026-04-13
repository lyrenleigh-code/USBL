function [r_horiz, z_final, t_travel, theta_arr] = ray_trace(svp, z_src, z_rcv, launch_angle)
% RAY_TRACE 分层等梯度声线追踪
%
%   [r_horiz, z_final, t_travel, theta_arr] = ray_trace(svp, z_src, z_rcv, launch_angle)
%
%   输入:
%     svp          - Mx2 声速剖面 [深度(m), 声速(m/s)], 按深度升序
%     z_src        - 声源深度 (m)
%     z_rcv        - 接收器深度 (m)
%     launch_angle - 出射掠射角 (rad), 相对于水平面, 正值向下
%
%   输出:
%     r_horiz   - 水平距离 (m)
%     z_final   - 最终深度 (m)
%     t_travel  - 传播时间 (s)
%     theta_arr - 到达角 (rad), 相对于水平面
%
%   采用 Snell 定律分层追踪, 每层内声速线性变化(等梯度), 声线为圆弧

    % 在声源深度处插值声速
    c_src = interp1(svp(:,1), svp(:,2), z_src, 'linear', 'extrap');

    % Snell 常数: cos(theta)/c = const
    p = cos(launch_angle) / c_src;

    % 构造从声源到接收器的分层结构
    z_all = unique([svp(:,1); z_src; z_rcv]);
    z_all = sort(z_all);

    % 确定传播方向
    if z_rcv > z_src
        direction = 1;   % 向下传播
    else
        direction = -1;  % 向上传播
        z_all = flipud(z_all);
    end

    % 找到起止位置
    idx_start = find(abs(z_all - z_src) < 0.01, 1);
    idx_end   = find(abs(z_all - z_rcv) < 0.01, 1);
    if isempty(idx_start) || isempty(idx_end)
        error('声源或接收器深度不在声速剖面范围内');
    end

    r_horiz = 0;
    t_travel = 0;

    if direction > 0
        layer_indices = idx_start : idx_end-1;
    else
        layer_indices = idx_start : -1 : idx_end+1;
    end

    for li = layer_indices
        if direction > 0
            z1 = z_all(li);
            z2 = z_all(li+1);
        else
            z1 = z_all(li);
            z2 = z_all(li-1);
        end

        c1 = interp1(svp(:,1), svp(:,2), z1, 'linear', 'extrap');
        c2 = interp1(svp(:,1), svp(:,2), z2, 'linear', 'extrap');
        dz = abs(z2 - z1);

        if dz < 1e-6
            continue;
        end

        g = (c2 - c1) / (z2 - z1);  % 声速梯度 (1/s)

        % 检查是否发生全反射
        cos_theta1 = p * c1;
        if abs(cos_theta1) > 1
            break;  % 全反射,声线折返
        end
        theta1 = acos(abs(cos_theta1));  % 掠射角

        if abs(g) < 1e-8
            % 等声速层: 声线为直线
            dr = dz * tan(theta1);
            dt = dz / (c1 * sin(theta1) + 1e-30);
        else
            % 等梯度层: 声线为圆弧
            cos_theta2_val = p * c2;
            if abs(cos_theta2_val) > 1
                break;  % 全反射
            end
            theta2 = acos(abs(cos_theta2_val));

            R_curv = 1 / (abs(p) * abs(g));  % 曲率半径
            dr = abs(R_curv * (cos(theta1) - cos(theta2)));
            dt = abs(log(tan(theta2/2 + pi/4) / tan(theta1/2 + pi/4)) / g);
        end

        r_horiz = r_horiz + dr;
        t_travel = t_travel + dt;
    end

    z_final = z_rcv;

    % 到达角
    c_rcv = interp1(svp(:,1), svp(:,2), z_rcv, 'linear', 'extrap');
    cos_arr = p * c_rcv;
    if abs(cos_arr) <= 1
        theta_arr = acos(abs(cos_arr));
    else
        theta_arr = 0;  % 退化情况
    end
end

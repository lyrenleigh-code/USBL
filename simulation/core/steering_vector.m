function a = steering_vector(theta, phi, pos, k)
% STEERING_VECTOR 计算阵列导向向量
%
%   a = steering_vector(theta, phi, pos, k)
%
%   输入:
%     theta - 极角/俯仰角 (rad), 0=阵法线方向(正下方), pi/2=阵面方向(水平)
%     phi   - 方位角 (rad), 0=x轴(前向)
%     pos   - Nx3 阵元位置矩阵 (m)
%     k     - 波数 = 2*pi*f/c
%
%   输出:
%     a - Nx1 复数导向向量
%
%   坐标系约定:
%     阵面在 xy 平面, 阵法线沿 z 轴正方向(向下)
%     远场平面波从 (theta, phi) 方向入射
%     方向余弦 u = [sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta)]

    % 入射方向的单位向量
    u = [sin(theta)*cos(phi); sin(theta)*sin(phi); cos(theta)];

    % 各阵元的相位延迟 (相对于阵列中心/坐标原点)
    % 正号: 波从远场传来, 先到达靠近源的阵元
    a = exp(1j * k * pos * u);
end

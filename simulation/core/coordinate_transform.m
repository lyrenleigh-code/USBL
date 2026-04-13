function [P_ned, P_geo] = coordinate_transform(R, theta, phi, ...
    install_angles, attitude, platform_pos)
% COORDINATE_TRANSFORM USBL坐标变换链: 阵坐标→载体→NED→地理
%
%   [P_ned, P_geo] = coordinate_transform(R, theta, phi, ...
%       install_angles, attitude, platform_pos)
%
%   输入:
%     R              - 斜距 (m)
%     theta          - 极角 (rad), 0=阵法线(下方)
%     phi            - 方位角 (rad), 0=前方
%     install_angles - [roll, pitch, yaw] 安装偏差角 (rad)
%     attitude       - [roll, pitch, heading] 平台姿态 (rad)
%     platform_pos   - [lat, lon, depth] 或 [x_ned, y_ned, z_ned]
%
%   输出:
%     P_ned - 目标在NED坐标系下的位置 (相对于平台)
%     P_geo - 目标在地理坐标系下的位置

    % 在阵坐标系中,目标的方向向量
    P_array = R * [sin(theta)*cos(phi); sin(theta)*sin(phi); cos(theta)];

    % 安装偏差旋转: 阵坐标系 → 载体坐标系
    R_install = euler2rotmat(install_angles(1), install_angles(2), install_angles(3));
    P_body = R_install * P_array;

    % 姿态旋转: 载体坐标系 → NED坐标系
    R_attitude = euler2rotmat(attitude(1), attitude(2), attitude(3));
    P_ned = R_attitude * P_body;

    % NED → 地理坐标 (简化: 直接加平台位置)
    if nargin >= 6 && ~isempty(platform_pos)
        P_geo = platform_pos(:) + P_ned;
    else
        P_geo = P_ned;
    end
end

function R = euler2rotmat(roll, pitch, yaw)
% EULER2ROTMAT 欧拉角转旋转矩阵 (ZYX顺序: 先偏航, 再俯仰, 最后横滚)
%
%   R = euler2rotmat(roll, pitch, yaw)
%
%   输入: (全部为弧度)
%     roll  - 横摇角 (绕x轴旋转)
%     pitch - 纵摇角 (绕y轴旋转)
%     yaw   - 偏航/艏向角 (绕z轴旋转)
%
%   输出:
%     R - 3x3 旋转矩阵, 将载体坐标系向量变换到参考坐标系
%         v_ref = R * v_body
%
%   旋转顺序: R = Rz(yaw) * Ry(pitch) * Rx(roll)

    cr = cos(roll);   sr = sin(roll);
    cp = cos(pitch);  sp = sin(pitch);
    cy = cos(yaw);    sy = sin(yaw);

    R = [cy*cp,  cy*sp*sr - sy*cr,  cy*sp*cr + sy*sr;
         sy*cp,  sy*sp*sr + cy*cr,  sy*sp*cr - cy*sr;
         -sp,    cp*sr,             cp*cr            ];
end

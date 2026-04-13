function [mf_out, mf_env] = matched_filter_lfm(x, s_ref)
% MATCHED_FILTER_LFM 对多通道接收信号做LFM匹配滤波
%
%   [mf_out, mf_env] = matched_filter_lfm(x, s_ref)
%
%   输入:
%     x     - NxL 多通道接收数据 (N=通道数, L=数据长度)
%     s_ref - 1xM 参考信号 (LFM本地副本)
%
%   输出:
%     mf_out - NxK 匹配滤波复数输出
%     mf_env - NxK 匹配滤波包络(幅度)

    [N_ch, ~] = size(x);
    h = conj(fliplr(s_ref));  % 匹配滤波器脉冲响应 = 参考信号的时反共轭

    mf_out = zeros(N_ch, size(x,2) + length(h) - 1);
    for ch = 1:N_ch
        mf_out(ch,:) = conv(x(ch,:), h);
    end

    mf_env = abs(mf_out);
end

function array = create_array(cfg)
% CREATE_ARRAY 阵列工厂 dispatcher
%
%   array = create_array(cfg)
%
%   根据 cfg.array.type 分发到对应工厂函数。
%   支持类型：
%     - 'UCA5'  : 五元均匀圆阵（平面）      → create_uca5
%     - 'CAGE5' : 笼式五元立体阵           → create_cage5
%
%   任何下游代码（DOA 算法 / 敏感度分析 / 测试）都应优先调用本函数而非直接
%   调用 create_uca5 / create_cage5，以支持类型切换。

    if ~isfield(cfg, 'array') || ~isfield(cfg.array, 'type')
        error('create_array: 缺少 cfg.array.type 字段');
    end

    switch upper(cfg.array.type)
        case 'UCA5'
            array = create_uca5(cfg);
        case 'CAGE5'
            array = create_cage5(cfg);
        otherwise
            error('create_array: 不支持的阵型 "%s"，当前支持 UCA5 / CAGE5', ...
                  cfg.array.type);
    end
end

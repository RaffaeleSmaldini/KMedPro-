function [enhancedVolume] = CLAHE3D(volume, param)
    % CLAHE: Contrast Limited Adaptive Histogram Equalization 3D
    % Enhance contrast slice-by-slice
    % Valid Range values are:['full', 'original']
    % Valid Distribution types are:['exponential', 'rayleigh', 'uniform']
    if nargin < 1
        error("The algorithm needs at least the volume.")
    end
    %% Auto-set parameters if not in 'param'
    if nargin < 2
        param = {};
    end
    enhancedVolume = zeros(size(volume));
    if ~isfield(param, 'ClipLimit')
        param.ClipLimit = 0.01; % MATLAB DEFAULT SETTING
    end
    if ~isfield(param, 'Distribution')
        param.Distribution = 'rayleigh'; % PROJECT DEFAULT SETTING
    end
    if ~isfield(param, 'NumTiles')
        param.NumTiles = [8,8]; % MATLAB DEFAULT SETTING
    end
    if ~isfield(param, 'NBins')
        param.NBins = 256; % MATLAB DEFAULT SETTING
    end
    if ~isfield(param, 'Range')
        param.Range = 'full'; % MATLAB DEFAULT SETTING
    end
    if ~isfield(param, 'Alpha')
        param.Alpha = 0.4; % MATLAB DEFAULT SETTING
    end
    %% Enchant
    [~,~,numSlices] = size(volume);
    for i = 1:numSlices
            enhancedVolume(:, :, i) = adapthisteq(volume(:, :, i), ...
                'ClipLimit', param.ClipLimit, ...
                'Distribution', param.Distribution, ...
                'NumTiles', param.NumTiles, ...
                'NBins',param.NBins, ...
                'Range', param.Range, ...
                'Alpha', param.Alpha);
    end
end
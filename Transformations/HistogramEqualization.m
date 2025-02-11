function volume = HistogramEqualization(volume, param)
% HistEq adaptation of:
% https://github.com/PeppeJerry/BRATS-Image-processing/blob/main/Functions/Preprocess/HistogramEqualization.m
% Available CDF for voxel equalization: ['LINEAR_DESC', 'EXP_DESC', 'POWER_LAW', 'DEFAULT_N']
% Default: 'DEFAULT_N' -> cdf = ones(param.N, 1); | if default N = 256
    % Input-check
    if nargin < 1
        error("The algorithm needs at least the 'volume'.")
    end
    if nargin < 2

    end
    dims = size(volume);         % save original dims
    volume = reshape(volume, [], 1);  % reshape from 3D to 1D -> voxel array
    
    if isfield(param, 'type') && param.type ~= "DEFAULT"
        cdf = cdf_HE(param);
        volume = histeq(volume, cdf); % apply histeq on a specific cdf
    else
        % default histeq
        volume = histeq(volume);
    end
    
    volume = reshape(volume, dims);   % reshape back
end


function cdf = cdf_HE(param)
    % Set default N value
    if ~isfield(param, 'N')
        param.N = 256;
    end   
    switch param.type
        case 'LINEAR_DESC'    % apply linear function
            cdf = linspace(1, 0, param.N); 
        case 'EXP_DESC'       % apply exponential function
            if ~isfield(param, 'Lambda')
                param.Lambda = 0.05;
            end
            cdf = exp(-param.Lambda * (0:param.N-1));  
        case 'POWER_LAW'      % apply power-law function
            if ~isfield(param, 'Gamma')
                param.Gamma = 2;
            end
            cdf = (param.N - (0:param.N-1)).^param.Gamma;
        case 'DEFAULT_N'
            cdf = ones(param.N, 1);
        otherwise
            cdf = ones(256, 1);
    end
    cdf = cdf / sum(cdf);
end
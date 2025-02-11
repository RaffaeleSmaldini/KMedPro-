function volume = LogTransform(volume, k, N, logtype)
    % volume: 3D image - it can also accept 2D images
    % k: moltiplicative constant value (float): [k * logX(1 + N * double(volume))]
        % Default k: 1.5
    % N: Volume gain (float): k * logX(1 + N * double(volume))
        % Default N: 1
    % logtype - available: ['log2', 'log'] (string)
        % Default logtype: 'log'
    if nargin < 4
        logtype = 'log';
    end
    if nargin < 3
        N = 1;
    end
    if nargin < 2
        k = 1.5;
    end
    if nargin < 1
        error("The algorithm needs at least of the 'volume'.")
    end
    switch logtype
        case 'log2'
            volume = k * log2(1 + N * double(volume));
        case 'log'
            volume = k * log(1 + N * double(volume));
        otherwise
            error("The only available case are: ['log', 'log2']")
    end
end
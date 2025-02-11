function volume_hf = HomomorphicFilter3D(volume, D0, gammaH, gammaL)
    % volume: 3D image - it can also accept 2D images
    % D0: cut-off freq
    % gammaH: gain for high frequencies
    % gammaL: gain for low frequencies

    % Divide I (illumination) and R (reflectance) components using log 
    img_log = log1p(double(volume));      % (log1(p) handle log(0))

    % Fourier Transformation 
    img_fft = fftn(img_log);

    % Homomorphic Gaussian Filter
    dims = size(volume);
    [u, v, w] = ndgrid(1:dims(1), 1:dims(2), 1:max(1, dims(3))); % 2D or 3D
    u = u - floor(dims(1)/2); % Centralize coordinate for dim 1 -> u
    v = v - floor(dims(2)/2); % Centralize coordinate for dim 2 -> v
    if numel(dims) == 3
        w = w - floor(dims(3)/2); % Centralize coordinate for dim 3 -> w (if present)
        D = sqrt(u.^2 + v.^2 + w.^2);
    else
        D = sqrt(u.^2 + v.^2); % 2D -> w is not calculated
    end
    H = (gammaH - gammaL) * (1 - exp(-(D.^2) / (2 * D0^2))) + gammaL;

    % Apply Homomorphic Gaussian Filter in Fourier domain
    img_hf_fft = img_fft .* H;

    % Inverse Fourier Transform 
    img_hf_log = real(ifftn(img_hf_fft));

    % Convert back from log domain
    volume_hf = exp(img_hf_log) - 1;
end

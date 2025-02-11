function [image3D_denoised] = AnisotropicFilter3D(image3D, numIterations, gradientThreshold,show_metrics)
    %AnisotropicFilter3D - Perform Anisotropic denoising on a 3D MRI volume.
    % [Edge Preservation filtering]
    % Inputs:
    %    image3D - A 3D MRI volume ([X, Y, Z]) of intensity values.
    %    numIterations - Determines how many times the diffusion process is applied to the image. 
    %                    A higher number of iterations results in more diffusion (smoothing). (int)
    %                   Default: 20 / reducing noise further but also increases the risk of blurring fine details and edges
    %    gradientThreshold - Threshold for gradient magnitude that controls the sensitivity of the diffusion process to edges. 
    %                        The diffusion slows or stops near edges with gradient magnitudes above this threshold, preserving the edges. (float)
    %                   Default: 10 / If edges are too blurred, reduce "gradientThreshold" to better preserve edge details
    %    show_metrics - If true, calculate and display denoising metrics.

    %% Default parameter handling
    if nargin < 2
        numIterations = 20; % Default value to control filter' iterations
    end
    if nargin < 3
        gradientThreshold = 10; % Deafult threshold for gradient magnitude
    end
    if nargin < 4
        show_metrics = false; % Default: do not show metrics
    end

    %% Apply Anisotropic Filtering to 3D volume using imdiffusefilt
    image3D_denoised = imdiffusefilt(double(image3D), ...
    'NumberOfIterations', numIterations, ...
    'GradientThreshold', gradientThreshold);

    %% Calculate Metrics (if enabled)
    if show_metrics
        [nx, ny, nz] = size(image3D); % Dimensions of the 3D volume
        fprintf('################-Anisotropic F.-#################\n');
        fprintf('Calculating PSNR and SSIM for denoised slices...\n');
        DenoisingMetrics(image3D, image3D_denoised, nz);
    end
end
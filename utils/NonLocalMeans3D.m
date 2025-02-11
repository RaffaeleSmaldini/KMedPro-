function [image3D_denoised] = NonLocalMeans3D(image3D, DegreeOfSmoothing, show_metrics)
    %NonLocalMeans3D - Perform Non-Local Means denoising on a 3D MRI volume.
    %
    % Inputs:
    %    image3D - A 3D MRI volume ([X, Y, Z]) of intensity values.
    %    DegreeOfSmoothing - control the amount of smoothing.
                            % Default 0.2 --> range: [0-1]
    %    show_metrics - If true, calculate and display denoising metrics.

    %% Default parameter handling
    if nargin < 2
        DegreeOfSmoothing = 0.2; % Default value to control the amount of smoothing
    end
    if nargin < 3
        show_metrics = false; % Default: do not show metrics
    end

    %% Initialize Denoised Image Volume
    [nx, ny, nz] = size(image3D); % Dimensions of the 3D volume
    image3D_denoised = zeros(nx, ny, nz);

    %% Apply Non-Local Means to Each Slice
    for i = 1:nz
        % Extract the 2D slice along the z-dimension
        current_slice = image3D(:, :, i);
        
        % Apply Non-Local Means denoising using imnlmfilt (built-in function)
        denoised_slice = imnlmfilt(current_slice, 'DegreeOfSmoothing', DegreeOfSmoothing);
        % 'DegreeOfSmoothing' controls the amount of smoothing 

        % Store the denoised slice
        image3D_denoised(:, :, i) = denoised_slice;
    end

    %% Calculate Metrics (if enabled)
    if show_metrics
        fprintf('################-Non Local Means-#################\n');
        fprintf('Calculating PSNR and SSIM for denoised slices...\n');
        DenoisingMetrics(image3D, image3D_denoised, nz);
    end
end

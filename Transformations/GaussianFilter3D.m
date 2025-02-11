function image3D_denoised = GaussianFilter3D(image3D, sigma, show_metrics, use_filter)
    % GaussianFilter3D applies a 3D Gaussian filter to an MRI volume.
    % Inputs:
    %   mriImage   - A 3D MRI volume (e.g., size [X, Y, Z]) as a numeric array.
    %   sigma      - The standard deviation of the Gaussian kernel. A scalar or
    %                a 3-element vector for anisotropic filtering.
    %                Example: sigma = 1 or sigma = [1 1 2].
    %   filterSize - (Optional) The size of the Gaussian filter as a scalar or
    %                a 3-element vector (default determined by imgaussfilt3).
    if nargin < 2
        error('You must provide at least the mriImage and sigma.');
    end

    if nargin < 4
        % If filterSize is not provided, just use imgaussfilt3 defaults
        image3D_denoised = imgaussfilt3(image3D, sigma);
    else
        if use_filter == true
            % gaussian filter -> filter size should be at least 6 sigma + 1 
            % so if sigma 0.7 -> filterSize = [6, 6, 6] -> basically 6*0.7 + 1 =  5.2 
             kernel_val = ceil(sigma*6 + 1);
             if mod(kernel_val,2)==0
                 kernel_val = kernel_val - 1; % if it's even reduce by 1 
             end
             filterSize = [kernel_val, kernel_val, kernel_val];
            image3D_denoised = imgaussfilt3(image3D, sigma, 'FilterSize', filterSize);
        else
            % use_filter is false
            image3D_denoised = imgaussfilt3(image3D, sigma);
        end
    end
    if nargin < 3
        show_metrics = false;
    end
    %% Calculate Metrics (if enabled)
    if show_metrics
        [nx, ny, nz] = size(image3D); % Dimensions of the 3D volume
        fprintf('################-Gaussian-#################\n');
        fprintf('Calculating PSNR and SSIM for denoised slices...\n');
        DenoisingMetrics(image3D, image3D_denoised, nz);
    end

end

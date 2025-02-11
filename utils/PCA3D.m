function [image3D_denoised] = PCA3D(image3D, tau, show_metrics)
    % PCA - Perform standard PCA for denoising a 3D MRI image volume.
    %
    % Inputs:
    %    image3D - A 3D MRI volume ([X, Y, Z]) of intensity values.
    %    tau - Cumulative variance threshold. Default is 97% (0.97).
    %    show_metrics - If true, calculate and display denoising metrics (PSNR, SSIM).
    %
    % Outputs:
    %    image3D_denoised - The denoised 3D MRI volume.

    %% Default parameter handling
    if nargin < 2
        tau = 0.97; % Default cumulative explained variance threshold
    end
    if nargin < 3
        show_metrics = false; % Default: do not show metrics
    end

    %% Reshape data
    % Reshape the 3D MRI volume into a 2D matrix (flatten spatial dimensions)
    [nx, ny, nz] = size(image3D);
    data = reshape(image3D, [], nz); % Flatten along Z slices

    %% Perform PCA on the flattened data
    % Subtract the mean of the data
    data_mean = mean(data, 2); % Mean for each voxel across slices
    data_centered = data - data_mean; % Centered data
    
    % Perform PCA using SVD (Singular Value Decomposition)
    [U, S, V] = svd(data_centered, 'econ'); 
    % U: Left singular vectors, S: Singular values, V: Right singular vectors

    % Compute cumulative explained variance (CEV)
    singular_values = diag(S);
    lambda_cumsum = cumsum(singular_values.^2) / sum(singular_values.^2);
    k = find(lambda_cumsum >= tau, 1); % Find the number of components to retain

    %% Project data onto principal components and reconstruct
    % Reduce the dimensionality using the top-k components
    V_k = V(:, 1:k); % Top-k principal components
    data_reduced = data_centered * V_k; % Project data onto principal components

    % Reconstruct the data from the reduced components
    data_reconstructed = (data_reduced * V_k') + data_mean; % Add back the mean

    %% Reshape reconstructed data back to 3D
    image3D_denoised = reshape(data_reconstructed, nx, ny, nz); % Reshape to original size

    %% Calculate Metrics (if enabled)
    if show_metrics
        fprintf('################-PCA-#################\n');
        fprintf('Calculating PSNR and SSIM for denoised slices...\n');
        DenoisingMetrics(image3D, image3D_denoised, nz);
    end
end
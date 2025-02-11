function [maskedVolume] = kMedROI(volume, param)
    % kMedROI: K-Mean, Density Wise ROI Preprocessing Pipeline
    if nargin < 1
        error("The algorithm needs at least the 'volume'. ")
    end
    % Set param if not specified
    if nargin < 2
        param = {};
    end
    [param] = init_kMedROI(param);
    original_volume = volume; % save the original volume for later
    %% Pre-process the volume for k-means segmentation
    % Rescale intensity for better contrast
    volume = mat2gray(volume);
    % Normalization
    volume = MinMaxNorm3D(volume);
    % Gaussian Smoothing
    volume = GaussianFilter3D(volume, param.gaussian_sigma, false, true); 
    % Median Filter
    volume = medfilt3(volume); 
    %% Kmeans Segmentation
    [clustered_volume, ~] = KmeansThresholding(volume, param.kmeans_clusters);
    %% Kmeans Mask Morphological Processing
    % Opening n1
    clustered_volume = imopen(clustered_volume, strel('sphere', param.sphere_opening1));
    % Closing n1
    clustered_volume = imclose(clustered_volume, strel('sphere', param.sphere_closing1));
    %% ROI masking
    roi_masking = sliceWiseROI(clustered_volume, param.roi_param);
    %% Sobel Edge detection
    gradient_magnitude = imgradient3(roi_masking, 'sobel');
    %% Apply the Sobel edge to mask transformation to the normalized volume
    gradient_mask = imclose(gradient_magnitude, strel('disk', param.disk_closing2));
    gradient_mask = gradient_mask > 0.5;
    gradient_mask = imfill(gradient_mask, [1, 1, 1]);
    gradient_mask = ~gradient_mask;
    %% Active Contouring Mask Refining
    contoured_mask = activecontour(volume, gradient_mask, param.ac_iters, 'Chan-Vese');
    %% Mask out the irrelevant part of the image
    maskedVolume = original_volume .* contoured_mask;
end

function [param] = init_kMedROI(param)
    if ~isfield(param, 'gaussian_sigma')
        param.gaussian_sigma = 0.6; % project default
    end
    if ~isfield(param, 'kmeans_clusters')
        param.kmeans_clusters = 4; % project default
    end
    if ~isfield(param, 'sphere_opening1')
        param.sphere_opening1 = 3; % project default
    end
    if ~isfield(param, 'sphere_closing1')
        param.sphere_closing1 = 2; % project default
    end  
    if ~isfield(param, 'disk_closing2')
        param.disk_closing2 = 2; % project default
    end  
    if ~isfield(param, 'roi_param')
        disp(['WARNING: sliceROIWise function automatically sets ' ...
            'all parameters with no density weighting;\n Use *help sliceWiseROI* ' ...
            'to see all parameters.\n ' ...
            'To set a sliceWiseROI param use: *kMedROI_param.roi_param.PARAMNAME*'])
        param.roi_param = {};
    end 
    if ~isfield(param, 'ac_iters')
        param.ac_iters = 13; % project default
    end
end
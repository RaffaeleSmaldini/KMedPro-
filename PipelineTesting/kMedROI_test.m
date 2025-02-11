%% Call Local Init
pathstr = m_local_init_m;
%% Function to import data using the DataLoader Function
    % Input: 
    %   pathstr: path of the dataset, implementend in the previous step; 
    %   String Values: that is the name of the organ, in his case: Prostate
    % Output: actual data
Data = DataLoader(pathstr, "Prostate");
disp(Data)

%% TEST pre-process
trainingIndex = 1; 
original_volume = Data.training(trainingIndex).image(:, :, :, 2);
volume = original_volume;
trueMask = Data.training(trainingIndex).label;
sliceIndex = round(size(volume, 3) / 2); % display central slice

% display data with no intensity rescale
DisplaySample(Data, trainingIndex, sliceIndex)

%% minmax mask 
trueMask = MinMaxNorm3D(trueMask); %data presents some pixels with 2 (white) instead of 1
%% Pre-processing
% Rescale intensity for better contrast
volume = mat2gray(volume); r = volume;
% Normalization
volume = MinMaxNorm3D(volume); norm = volume;
% Gaussian Smoothing
sigma = 0.6;%0.65;
volume = GaussianFilter3D(volume, sigma, false, true); gau = volume;
% Median Filter
volume = medfilt3(volume); med = volume;

% show transformations
ShowSliceImages({r, norm, gau, med},{'rescaled intensity','normalized', ...
    'gaussian', 'median filter'},sliceIndex)

%% Kmeans
nclusters = 4;
[clustered_volume, kmeans_thresholds] = KmeansThresholding(volume, nclusters);
disp(kmeans_thresholds)
% Figure after Kmeans
figure
imshow(clustered_volume(:,:,sliceIndex), []);
title('Kmeans Initial Segmentation (Slice)');

%% Kmeans Mask Morphological Processing
% Opening
clustered_volume = imopen(clustered_volume, strel('sphere', 3));
% Opening Figure
figure
imshow(clustered_volume(:,:,sliceIndex), []);
title('Kmeans Opening Segmentation (Slice)');

clustered_volume = imfill(clustered_volume, 'holes');

% Closing
clustered_volume = imclose(clustered_volume, strel('sphere', 2));
% Closing Figure
figure
imshow(clustered_volume(:,:,sliceIndex), []);
title('Kmeans Closing Segmentation (Slice)');

%% ROI masking
roi_param.base_scaler = 0.4;
% if sigmoid
roi_param.k = 1.5;
roi_param.sigmoid_threshold = 0.35; 
%%
roi_param.use_density_adapt_radius = true;
roi_param.type = 'log';
roi_masking = sliceWiseROI(clustered_volume, roi_param);
% show ROI masking
figure
imshow(roi_masking(:,:,sliceIndex), []);
title('ROI Mask (Slice)');

%% Sobel Edge detection
gradient_magnitude = imgradient3(roi_masking, 'sobel');
% Gradient Edges Figure
figure
imshow(gradient_magnitude(:,:,sliceIndex), []);
title('Sobel Edges (Slice)');

%% Apply the Sobel edge to mask transformation to the normalized volume
gradient_mask = imclose(gradient_magnitude, strel('disk', 2)); %2D closing for  smooth curves
gradient_mask = gradient_mask > 0.5;
gradient_mask = imfill(gradient_mask, [1, 1, 1]);
gradient_mask = ~gradient_mask;

% show Gradient Mask
figure
imshow(gradient_mask(:,:,sliceIndex), []);
title('Gradient Mask (Slice)');

contoured_mask = activecontour(volume, gradient_mask, 13, 'Chan-Vese'); %12, 'Chan-Vese');
% show Refined Contoured Mask
figure
imshow(contoured_mask(:,:,sliceIndex), []);
title('Refined Contoured Mask (Slice)');

% mask out the irrelevant part of the image
maskedVolume = original_volume .* contoured_mask;
% show Masked Volume
figure
imshow(maskedVolume(:,:,sliceIndex), []);
title('Masked Volume (Slice)');

%define clusters
nclusters = 3;
%% Kmeans with refined image 
maskedVolume = mat2gray(maskedVolume); 
% Normalization
maskedVolume = MinMaxNorm3D(maskedVolume);
%% K-means thresholding
[maskedClusteredVolume, kmeans_thresholds] = KmeansThresholding(maskedVolume, nclusters);
disp("#######finals thresholds#######")
disp(kmeans_thresholds)
% Kmean post-processing: Morphological Operations
% Use a small radius for minor corrections, removing noise or filling small gaps in segmentation
% Opening
maskedClusteredVolume = imopen(maskedClusteredVolume, strel('sphere', 2)); %3
% Closing
maskedClusteredVolume = imclose(maskedClusteredVolume, strel('sphere', 2)); %3

% Watershed post-processing: Morphological Operations
%maskedClusteredVolume = imclose(maskedClusteredVolume, strel('sphere', 1));
%maskedClusteredVolume = imfill(maskedClusteredVolume, 'holes');

%% Show figure
% Figure after segmentation
figure
imshow(maskedClusteredVolume(:,:,sliceIndex), []);
title('Segmentation before Labelling (Slice)');

% define tumor mask
final_result = fitOverlapMask(trueMask, maskedClusteredVolume);

% Figure after Labelling
figure
imshow(final_result(:,:,sliceIndex), []);
title('Final Segmentation (Slice)');

%% Shows overlap
showOverlap(trueMask, final_result);

%% Metrics
calculateMetrics = @(trueMask, predicted) struct( ...
    'DiceCoeff', calculateDice(trueMask, predicted), ...
    'IoU', calculateIoU(trueMask, predicted), ...
    'MostDenseSlice', defineDensestSlice(trueMask), ...
    'DiceMostDenseSlice', calculateDice(trueMask(:,:,defineDensestSlice(trueMask)), predicted(:,:,defineDensestSlice(trueMask))), ...
    'IoUMostDenseSlice', calculateIoU(trueMask(:,:,defineDensestSlice(trueMask)), predicted(:,:,defineDensestSlice(trueMask))) ...
);

% Calculation
result = calculateMetrics(trueMask, final_result); 
fprintf('Dice: %f\n', result.DiceCoeff);
fprintf('IoU: %f\n',result.IoU);
fprintf('Most densest slice Dice: %f\n',result.DiceMostDenseSlice);
fprintf('Most densest slice IoU: %f\n',result.IoUMostDenseSlice);


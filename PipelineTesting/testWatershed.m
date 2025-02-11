 %% INIT HYPER PARAMS
anisotropic_iterations = 5; %number of iterations for anisotropic filter
anisotropic_gthreshold = 0.06;  %gradient threshold for anisotropic filter
D0 = 150; % cut-off for homomorphic filter  % 150
gammaH = 1; % gain for high freq % 1
gammaL = 0.1; %gain for low freq % 0.1
smallObjThreshold = 200; % pixel threshold for bwopen in post process watershed segmentation
sol_threshold = 0.32; % threshold for solarization %% 0.33
sharpenStacks = 1; % times that sharpen filter will be applied

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
trainingIndex = 12; 
volume = Data.training(trainingIndex).image(:, :, :, 2);
trueMask = Data.training(trainingIndex).label;
sliceIndex = round(size(volume, 3) / 2); % display central slice

% display data with no intensity rescale
DisplaySample(Data, trainingIndex, sliceIndex)

%% Pre-processing
% Rescale intensity for better contrast
volume = mat2gray(volume); r = volume;
% Normalization
volume = MinMaxNorm3D(volume); norm = volume;
%volume = StandardScaler3D(volume); norm = volume;
% Solarize
% volume = NormalizedSolarize(volume, sol_threshold); sol = volume;
% Inverse Volume
volume = Invert(volume); c = volume;
% Anisotropic Filter
volume = AnisotropicFilter3D(volume, anisotropic_iterations, anisotropic_gthreshold, true); an = volume;
% Homomorphic Transformation
volume = HomomorphicFilter3D(volume, D0, gammaH, gammaL); h = volume;
% Sharp Edges
volume = Sharpen3D(volume, sharpenStacks); sharp = volume;
% Log Transform
k = 1.5; N = 1; % Log transform constants
volume = LogTransform(volume, k); log_volume = volume;

ShowSliceImages({r, norm, h, c, an, sharp, log_volume},{'rescaled intensity','normalized', ...
    'homomorphic','inverse', 'anisotropic filter', 'sharpen', 'log transform'},sliceIndex)

%% Segmentation
model_params.trueMask = trueMask; 
model_params.minimaDepthRange = linspace(0.2, 0.38, 18); 
model_params.smallObjectsThreshold = smallObjThreshold; 
model_params.verbose = true;
model_params.show_slice = true;
model_params.train_mode = true;
% Watershed

[segmentedVolume, optimalMinimaDepth, bestDice] = watershedSegmentation( ...
    volume, model_params);



%% Post-processing: Morphological Operations
tic
se = strel('sphere', 1); % Structural element for morphological processing
final_result = imclose(segmentedVolume, se);
final_result = imfill(final_result, 'holes');
toc
% Figure after Post-processing /Watershed/
figure
imshow(final_result(:,:,sliceIndex), []);
title('Refined Watershed Segmented Tumor (Slice)');



%% Metrics
calculateMetrics = @(trueMask, predicted) struct( ...
    'DiceCoeff', calculateDice(trueMask, predicted), ...
    'IoU', calculateIoU(trueMask, predicted), ...
    'MostDenseSlice', defineDensestSlice(trueMask), ...
    'DiceMostDenseSlice', calculateDice(trueMask(:,:,defineDensestSlice(trueMask)), predicted(:,:,defineDensestSlice(trueMask))), ...
    'IoUMostDenseSlice', calculateIoU(trueMask(:,:,defineDensestSlice(trueMask)), predicted(:,:,defineDensestSlice(trueMask))) ...
);

% Calculation
% switch 'segmentedVolume' with 'final_result' when using Watershed
result = calculateMetrics(trueMask, final_result); 
fprintf('Dice: %f\n', result.DiceCoeff);
fprintf('IoU: %f\n',result.IoU);
fprintf('Most densest slice Dice: %f\n',result.DiceMostDenseSlice);
fprintf('Most densest slice IoU: %f\n',result.IoUMostDenseSlice);
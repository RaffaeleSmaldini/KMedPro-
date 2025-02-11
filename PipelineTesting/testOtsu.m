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
trainingIndex = 15; 
volume = Data.training(trainingIndex).image(:, :, :, 2);
trueMask = Data.training(trainingIndex).label;
sliceIndex = round(size(volume, 3) / 2); % display central slice

% display data with no intensity rescale
DisplaySample(Data, trainingIndex, sliceIndex)

%% kMedROI
% set params for kMedROI
kMedROI_param.roi_param.base_scaler = 0.4; 
kMedROI_param.roi_param.use_density_adapt_radius = true; 
kMedROI_param.roi_param.type = 'log';
% Apply k-Means SliceWiseROI Refining
tic
volume = kMedROI(volume, kMedROI_param); % return masked volume
fprintf("Elapsed time for kMedROI: %.2f seconds\n", toc)

%% Pre-processing
% Rescale intensity for better contrast
volume = mat2gray(volume); r = volume;
% Normalization
volume = MinMaxNorm3D(volume); norm = volume;

% % Adaptive histogram equalization CLAHE
% CLAHE_param.Distribution = 'rayleigh';
% CLAHE_param.Range = 'original';
% CLAHE_param.NBins = 64;
% CLAHE_param.NumTiles = [3,3];
% CLAHE_param.ClipLimit = 0.02;
% CLAHE_param.Alpha = 0.5; 
% volume = CLAHE3D(volume, CLAHE_param); hist = volume;

% PCA 
tau = 0.95; % CEV to keep
volume = PCA3D(volume, tau, true); pca_image = volume;

%Gaussian Filter
sigma = 0.9;
volume = GaussianFilter3D(volume, sigma, true); gau = volume;

% Anistropic Filter
anisotropic_iterations = 5; %number of iterations for anisotropic filter % 5
anisotropic_gthreshold = 0.1;  %gradient threshold for anisotropic filter % 0.1
volume = AnisotropicFilter3D(volume, anisotropic_iterations, ...
    anisotropic_gthreshold, true);

% Homomorphic
% MEDIUM RESULTS WITHOUT kMedROI
% D0 = 2; % cut-off for homomorphic filter  
% gammaH = 4; % gain for high freq 
% gammaL = 1; %gain for low freq 
D0 = 1.5; % cut-off for homomorphic filter   | 1.5 
gammaH = 2; % gain for high freq             | 2
gammaL = 1; %gain for low freq               | 1
volume = HomomorphicFilter3D(volume, D0, gammaH, gammaL); h = volume;
volume = LogTransform(volume, 0.1, 0.1, 'log'); log = volume;

ShowSliceImages({r, norm, pca_image, gau, h, log},{'rescaled intensity','normalized', ...
    'pca', 'gaussian', 'homomorphic', 'log'},sliceIndex)


%% Segmentation 
% Otsu
ncluster = 3;   % 3 DICE =  0.586 | 0.51 (better qualitative)
[segmentedVolume, Otsu_T] = OtsuThreshold(volume, ncluster);
% Figure BEFORE Post-processing /Otsu/
figure
imshow(segmentedVolume(:,:,sliceIndex), []);
title('Otsu Output Mask Tumor (Slice)');

% ########## DEBUG THRESHOLDING ##########
disp("########## DEBUG THRESHOLDING ##########")
fprintf('Threshold: %f\n', Otsu_T)
uniqueLabels = unique(segmentedVolume(:, :, sliceIndex));
disp('Unique labels in the segmented slice:');
disp(uniqueLabels);
figure;
imshow(segmentedVolume(:, :, sliceIndex), []);
colormap(jet); % Use a color map for better visualization
colorbar;
title('Labeled Segmentation');
% Extract intensities for each label
originalSlice = volume(:, :, sliceIndex); % Original pre-segmented image
for label = 1:4
    labelMask = (segmentedVolume(:, :, sliceIndex) == label);
    disp(['Label ', num2str(label), ': Intensity Range']);
    disp([min(originalSlice(labelMask)), max(originalSlice(labelMask))]);
end
disp("#########################################")
% #########################################

%% Post-processing
% Morphological Operations
tic
disp("Morphological ")
% strel = Structural element for morphological processing
segmentedVolume = imclose(segmentedVolume, strel('sphere', 2));
segmentedVolume = imfill(segmentedVolume, 'holes');
fprintf('time elasped for Morpological operations: %.2f\n', toc)

% Figure after Post-processing /Otsu/
figure
imshow(segmentedVolume(:,:,sliceIndex), []);
title('Otsu Output Mask Tumor (Slice) - PostP.');

%% defineLabels
segmentedVolume = defineLabels(segmentedVolume);
% Figure after label definition /Otsu/
figure
imshow(segmentedVolume(:,:,sliceIndex), []);
title('Otsu Labeled Segmented Tumor (Slice)');

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
result = calculateMetrics(trueMask, segmentedVolume); 
fprintf('Dice: %f\n', result.DiceCoeff);
fprintf('IoU: %f\n',result.IoU);
fprintf('Most densest slice Dice: %f\n',result.DiceMostDenseSlice);
fprintf('Most densest slice IoU: %f\n',result.IoUMostDenseSlice);

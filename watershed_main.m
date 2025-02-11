%% Globals | Metrics
pathstr = m_init_m; % init workings paths
global show_densest_slice;
show_densest_slice = true; % show the densest slice after processing for each training example

% init metrics
metrics.watershed_average_dice = 0;
metrics.average_final_dice = 0;
metrics.average_mostDense_dice = 0;
metrics.average_IoU = 0;
metrics.average_mostDense_IoU = 0;

%% Load Data
Data = DataLoader(pathstr, "Prostate");
disp(Data)
%% Init params
% Pipeline params
pipeline_param.type = 'watershedPipeline';
pipeline_param.anisotropic_iterations = 5; %number of iterations for anisotropic filter
pipeline_param.anisotropic_gthreshold = 0.06;  %gradient threshold for anisotropic filter
pipeline_param.D0 = 150; % cut-off for homomorphic filter  % 150
pipeline_param.gammaH = 1; % gain for high freq % 1
pipeline_param.gammaL = 0.1; %gain for low freq % 0.1
pipeline_param.k = 1.5; pipeline_param.N = 1; % Log transform constants

%% MAIN 
Data = Data.training; % Get only training data since test has no ground truth
% Split data in train and test
[~, num] = size(Data);
trainData = Data(1:25); testData = Data(26:num);
% models params
[~, num] = size(trainData);
model_params.type = 'watershed';
model_params.optimalMinimaDepthArray = zeros(1,num);
model_params.minimaDepthRange = linspace(0.2, 0.38, 18);
model_params.smallObjThreshold = 200; % pixel threshold for bwopen in post process watershed segmentation
model_params.verbose = false;
model_params.train_mode = true; % only watershed split the train and test procedure since needs a refining of minima depth
model_params.show_slice = false;

% define the post processing morphological operations 
function [bestFit] = morpho_func(bestFit)
    se = strel('sphere', 1); % Structural element for morphological processing
    bestFit = imclose(bestFit, se);
    bestFit = imfill(bestFit, 'holes');
end

% Train samples
% heuristic_params = 'skip'; ==>  watershed doesn't use the heuristic in Trainer method
Trainer(trainData, pipeline_param, model_params, metrics, @morpho_func, 'skip', 'skip')

% INIT FOR TEST
model_params.train_mode = false;
global meanMinima
model_params.depth = meanMinima; % use the meanMinima from Train
% Select tumor label heuristic params
model_params.heuristic_params.nbins = 128; % entropy colors bins
model_params.heuristic_params.weightSpatial = 10;  % penalize clusters distant from center (since is a centered ROI image)

% Test samples
% heuristic_params = 'skip'; ==>  watershed doesn't use the heuristic in
% Trainer method (ALSO IN TESTING)
Trainer(testData, pipeline_param, model_params, metrics, @morpho_func, 'skip', 'skip')

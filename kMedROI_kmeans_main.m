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

%% init models dependencies
% set params for kMedROI
kMedROI_param.roi_param.base_scaler = 0.4; 
kMedROI_param.roi_param.use_density_adapt_radius = true; 
kMedROI_param.roi_param.type = 'log';
% Pipeline params
pipeline_param.type = 'watershedPipeline'; % choose the pipeline in "preProcessingPipelines"
pipeline_param.anisotropic_iterations = 5; %number of iterations for anisotropic filter
pipeline_param.anisotropic_gthreshold = 0.06;  %gradient threshold for anisotropic filter
pipeline_param.D0 = 150; % cut-off for homomorphic filter  % 150
pipeline_param.gammaH = 1; % gain for high freq % 1
pipeline_param.gammaL = 0.1; %gain for low freq % 0.1
pipeline_param.smallObjThreshold = 200; % pixel threshold for bwopen in post process watershed segmentation
pipeline_param.k = 1.5; pipeline_param.N = 1; % Log transform constants
% Refiner model params
model_params.type = 'kmeans';
model_params.nclusters = 3; % clusters for second kmeans to segment the final mask

%% MAIN 
Data = Data.training; % Get only training data since test has no ground truth
[~, num] = size(Data);
trainData = Data(1:25); testData = Data(26:num);

% define the post processing morphological operations 
function [bestFit] = morpho_func(bestFit)
    bestFit = imfill(bestFit, 'holes'); % Fill holes
    % Use a small radius for minor corrections, removing noise or filling small gaps in segmentation
    % Opening
    bestFit = imopen(bestFit, strel('sphere', 3)); %3
    % Closing
    bestFit = imclose(bestFit, strel('sphere', 3)); %3
end

pipeline_param.type = 'None'; % no pipeline after kMedROI
% start training to observe model performances using fitOverlapMask (trueMask overlapped with prediction to choose cluster)
use_fit_overlap = true; % use fitOverlapMask to evaluete the heuristic for tumor region
TrainerMedROI(trainData, kMedROI_param, pipeline_param, model_params, metrics, @morpho_func, use_fit_overlap)

% Select tumor label heuristic params
heuristic_params.nbins = 64; % entropy colors bins
heuristic_params.weightSpatial = 0.4;  % penalize clusters distant from center (since is a centered ROI image)
% otherwise use:
% heuristic_params = 'skip'; % in TRAIN

% start test to observe model performances using sliceWiseTumourHeu (heuristic calculation to find the tumour' cluster)
use_fit_overlap = false; % set to false the fitOverlapMask to evaluete the heuristic for tumor region
% we still use Trainer since we want to evaluate performances w.r.t.
% trueMask (not using it to choose tumour cluster!!)
TrainerMedROI(testData, kMedROI_param, pipeline_param, model_params, metrics, @morpho_func, use_fit_overlap, heuristic_params)





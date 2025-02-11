%% Globals | Metrics
pathstr = m_init_m; % init workings paths
global show_densest_slice;
show_densest_slice = false; % show the densest slice after processing for each training example

% init metrics
metrics.watershed_average_dice = 0;
metrics.average_final_dice = 0;
metrics.average_mostDense_dice = 0;
metrics.average_IoU = 0;
metrics.average_mostDense_IoU = 0;

%% Load Data
Data = DataLoader(pathstr, "Heart");
disp(Data)

%% init models dependencies
% set params for kMedROI
kMedROI_param.roi_param.base_scaler = 0.15; 
kMedROI_param.roi_param.use_density_adapt_radius = true; 
kMedROI_param.roi_param.type = 'milder';
% Pipeline params
pipeline_param.type = 'otsuPipeline'; % choose the pipeline in "preProcessingPipelines"
pipeline_param.tau = 0.95; % CEV to keep
pipeline_param.sigma = 0.9; % gaussian sigma value
pipeline_param.anisotropic_iterations = 5; %number of iterations for anisotropic filter 
pipeline_param.anisotropic_gthreshold = 0.1;  %gradient threshold for anisotropic filter 
pipeline_param.D0 = 1.5; % cut-off for homomorphic filter  
pipeline_param.gammaH = 2; % gain for high freq 
pipeline_param.gammaL = 1; %gain for low freq 
pipeline_param.k = 0.1; % log transform
pipeline_param.N = 0.1; % log transform
pipeline_param.logtype = 'log'; % log transform
% Refiner model params
model_params.type = 'otsu';
model_params.nclusters = 2; % clusters for second kmeans to segment the final mask

%% MAIN 
Data = Data.training; % Get only training data since test has no ground truth
[~, num] = size(Data);
trainData = Data(1:15); testData = Data(16:num);

% define the post processing morphological operations 
function [bestFit] = morpho_func(bestFit)
    % strel = Structural element for morphological processing
    bestFit = imclose(bestFit, strel('sphere', 2));
    bestFit = imfill(bestFit, 'holes');
end

% start training to observe model performances using fitOverlapMask (trueMask overlapped with prediction to choose cluster)
use_fit_overlap = true; % use fitOverlapMask to evaluete the heuristic for tumor region
TrainerMedROI(trainData, kMedROI_param, pipeline_param, model_params, metrics, @morpho_func, use_fit_overlap)

% Select tumor label heuristic params
heuristic_params.nbins = 128; % entropy colors bins
heuristic_params.weightSpatial = 0.4;  % penalize clusters distant from center (since is a centered ROI image)
% otherwise use:
% heuristic_params = 'skip'; % in TRAIN

% start test to observe model performances using sliceWiseTumourHeu (heuristic calculation to find the tumour' cluster)
use_fit_overlap = false; % set to false the fitOverlapMask to evaluete the heuristic for tumor region
% we still use Trainer since we want to evaluate performances w.r.t.
% trueMask (not using it to choose tumour cluster!!)
TrainerMedROI(testData, kMedROI_param, pipeline_param, model_params, metrics, @morpho_func, use_fit_overlap, heuristic_params)





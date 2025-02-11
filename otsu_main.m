%% Globals | Metrics
pathstr = m_init_m; % init workings paths
global show_densest_slice;
show_densest_slice = true; % show the densest slice after processing for each training example

% init metrics
metrics.average_final_dice = 0;
metrics.average_mostDense_dice = 0;
metrics.average_IoU = 0;
metrics.average_mostDense_IoU = 0;

%% Load Data
Data = DataLoader(pathstr, "Prostate");
disp(Data)

%% Init values
% Pipeline params
pipeline_param.type = 'otsuPipeline';
pipeline_param.tau = 0.95; % CEV to keep
pipeline_param.sigma = 2; % gaussian sigma value
pipeline_param.anisotropic_iterations = 5; %number of iterations for anisotropic filter 
pipeline_param.anisotropic_gthreshold = 0.1;  %gradient threshold for anisotropic filter 
pipeline_param.D0 = 2; % cut-off for homomorphic filter  
pipeline_param.gammaH = 4; % gain for high freq 
pipeline_param.gammaL = 1; %gain for low freq 
pipeline_param.k = 0.1; % log transform
pipeline_param.N = 0.1; % log transform
pipeline_param.logtype = 'log'; % log transform

%% MAIN 
Data = Data.training; % Get only training data since test has no ground truth
% models params
[~, num] = size(Data);
model_params.type = 'otsu';
model_params.nclusters = 2;
% Split data in train and test
trainData = Data(1:25); testData = Data(26:num);

function [bestFit] = morpho_func(bestFit)
    % strel = Structural element for morphological processing
    bestFit = imclose(bestFit, strel('sphere', 2));
    bestFit = imfill(bestFit, 'holes');
end

% start training to observe model performances using fitOverlapMask (trueMask overlapped with prediction to choose cluster)
use_fit_overlap = true;
Trainer(trainData, pipeline_param, model_params, metrics, @morpho_func, use_fit_overlap)

% Select tumor label heuristic params
heuristic_params.nbins = 128; % entropy colors bins
heuristic_params.weightSpatial = 10;  % penalize clusters distant from center (since is a centered ROI image)

% start test to observe model performances using sliceWiseTumourHeu (heuristic calculation to find the tumour' cluster)
use_fit_overlap = false;
% we still use Trainer since we want to evaluate performances w.r.t.
% trueMask (not using it to choose tumour cluster!!)
Trainer(testData, pipeline_param, model_params, metrics, @morpho_func, use_fit_overlap, heuristic_params)
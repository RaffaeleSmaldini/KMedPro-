function [pathstr] = m_init_m()
    %% ------------ LOAD MODULES ------------- %  
    clc;
    fprintf("Cleaning workspace..")
    clear all; close all force; clear global;   
    pause(1);
    fprintf("Done.")
    %% Import of file, dataset and setting up the environment
    mainFile = mfilename('fullpath');
    [pathstr,~,~] = fileparts(mainFile);
    display(pathstr) %print the path of the dataset
    addpath(fullfile(pathstr, 'utils')); % Set Path for utils functions
    addpath(fullfile(pathstr, 'Trainer')); % Set Path for trainer functions and models
    addpath(fullfile(pathstr, 'Trainer','Metrics')); % Set Path for Metrics
    addpath(fullfile(pathstr, 'Transformations')); % Set Path for transformations functions
    addpath(fullfile(pathstr, 'preProcessingPipelines')); % Set Path for preprocessing functions
end
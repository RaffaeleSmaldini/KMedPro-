function [] = TrainerMedROI(Data, kMedROI_param, pipeline_param, model_params, metrics, morpho_func, use_fit_overlap, heuristic_params)
    if ~exist('model_params', 'var')
        error("WARNING: 'model_params' do not exist, the algorithm depends on the model parameters; " + ...
            "Consult the 'NAMEMODEL.m' to choose the parameters.")
    end
    if ~exist('use_fit_overlap', 'var')
        use_fit_overlap = false;
    elseif use_fit_overlap == true
        fprintf("WARNING: 'use_fit_overlap' is set to true; this overlap " + ...
            "the trueMask to find the actual tumor region obtained through segmentation." + ...
            "Use this only to compare and optimize the heuristic to detect " + ...
            "the tumor region w.r.t. the output\n")
    end
    [~, num] = size(Data);
    for i = 1:num
        fprintf("######-- Sample n*%d --######\n", i)
        tic
        %% select training example
        try
            volume = Data(i).image(:, :, :, 2);
        catch ME
            volume = Data(i).image(:, :, :, 1);
        end
        original_volume = volume; % save for best fit heuristic
        trueMask = Data(i).label;
        %% minmax mask 
        % data presents some pixels with 2 (white) instead of 1
        trueMask = MinMaxNorm3D(trueMask); 
        %% Apply k-Means SliceWiseROI Refining
        tic
        maskedVolume = kMedROI(volume, kMedROI_param);
        fprintf("Elapsed time for kMedROI: %.2f seconds\n", toc)    
        % maskedVolume is the original image, masked using the kMeans refinend with density ROI area exclusion + active contouring
        %% pre-Processing with pipelines
        if strcmp(pipeline_param.type, 'watershedPipeline') 
            fprintf("Watershed Pipeline selected..")
            % watershed pipeline: here we have the volumeMasked and preprocessed in the same way as "watershedTraining.m"
            maskedVolume = watershedPipeline(maskedVolume, pipeline_param); 
        elseif strcmp(pipeline_param.type, 'otsuPipeline') % otsu pipeline:
            fprintf("Otsu Pipeline selected..")
            maskedVolume = otsuPipeline(maskedVolume, pipeline_param);
        elseif strcmp(pipeline_param.type, 'kmeansPipeline')
            fprintf("KMeans Pipeline selected..")
            maskedVolume = kmeansPipeline(maskedVolume, pipeline_param);
        elseif strcmp(pipeline_param.type, 'None') || strcmp(pipeline_param.type, '')
            fprintf("No Pipeline selected..")
            % No operations
        else
            error("ERROR: %s pipeline isn't supported; try with ['watershedPipeline', 'otsuPipeline', 'kmeansPipeline', 'None']", pipeline_param.type)
        end
        %% Segment with the choosen model
        if strcmp(model_params.type, 'kmeans')
            [segmentedVolume, ~] = KmeansThresholding(maskedVolume, model_params.nclusters);
        elseif strcmp(model_params.type, 'otsu')
            [segmentedVolume, ~] = OtsuThreshold(maskedVolume, model_params.nclusters);
        else
            error("ERROR: %s model isn't supported; try with ['otsu', 'kmeans']", model_params.type)
        end
        %% Adjust Labels for metrics calculation
        if use_fit_overlap
            % ### adjust labels using the fitOverlapMask (needs the trueMask) ###
            % useful to tune the heuristic
            bestFit = fitOverlapMask(trueMask, segmentedVolume);
        else
            % ### WTHe adjust labels using the defineLabels (don't need the trueMask) ###
            bestFit = sliceWiseTumourHeu(segmentedVolume, original_volume, heuristic_params);
        end
        %% Morphological operation to ajust the results
        if exist('morpho_func', 'var') && isa(morpho_func, 'function_handle')
            fprintf("Using morpho_func...\n")
            bestFit = morpho_func(bestFit); % Call the morphological operation function if present
        end
        final_result = bestFit;
        %% Evaluate the prediction
        metrics = Evaluation(metrics, trueMask, final_result, ...
            original_volume, segmentedVolume, maskedVolume);
    end
    printAverageMetrics(metrics, num)
end

function [metrics] = Evaluation(metrics, trueMask, final_result, ...
    original_volume, segmentedVolume, maskedVolume)
    %% Metrics calculation
    final_dice = calculateDice(trueMask, final_result);
    metrics.average_final_dice = metrics.average_final_dice + final_dice;
    fprintf("final DICE: %.4f\n", final_dice)
    IoU = calculateIoU(trueMask, final_result);
    fprintf("IoU: %.4f\n", IoU)
    metrics.average_IoU = metrics.average_IoU + IoU;
    % calculate densest slice and its metrics
    densest = defineDensestSlice(trueMask);
    mostDense_slice_dice = calculateDice(trueMask(:,:,densest), final_result(:,:,densest));
    fprintf("most dense slice DICE: %.4f\n", mostDense_slice_dice)
    mostDense_slice_IoU = calculateIoU(trueMask(:,:,densest), final_result(:,:,densest));
    fprintf("most dense slice IoU: %.4f\n", mostDense_slice_IoU)
    metrics.average_mostDense_dice = metrics.average_mostDense_dice + mostDense_slice_dice;
    metrics.average_mostDense_IoU = metrics.average_mostDense_dice + mostDense_slice_IoU;
    % show 1 slice (densest) for each training example
    global show_densest_slice
    if show_densest_slice
        figure;
        % Original Slice
        subplot(1, 4, 1); 
        imshow(original_volume(:,:,densest), [])
        title('Original');
        % Masked Processed Slice
        subplot(1, 4, 2); 
        imshow(maskedVolume(:,:,densest), [])
        title('Masked Processed');
        % Model output figure
        subplot(1, 4, 3); 
        imshow(segmentedVolume(:,:,densest), [])
        title('Segmented');
        % Figure after post-Processing
        subplot(1, 4, 4); 
        imshow(final_result(:,:,densest), []);
        title('Post-processing');
        % showOverlap: if true, last param show also the true mask in subplot
        showOverlap(trueMask, final_result, densest, true); 
        disp('Click on blank space of last figure to continue...');
        waitforbuttonpress; % Wait for mouse click
        disp('Resuming algorithm...');
        close all; % Close all open figures to free resources
    end
end

function [] = printAverageMetrics(metrics, num)
    metrics.average_final_dice = metrics.average_final_dice / num;
    metrics.average_IoU = metrics.average_IoU / num;
    metrics.average_mostDense_dice = metrics.average_mostDense_dice / num;
    metrics.average_mostDense_IoU = metrics.average_mostDense_IoU / num; 
    fprintf("######-- ####### --######\n")
    fprintf("Final Average DICE: %.4f\n", metrics.average_final_dice)
    fprintf("Average IoU: %.4f\n", metrics.average_IoU)
    fprintf("Most dense slice Average DICE: %.4f\n", metrics.average_mostDense_dice)
    fprintf("Most dense slice Average IoU: %.4f\n", metrics.average_mostDense_IoU)
end
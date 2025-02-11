function [segmentedVolume, optimalMinimaDepth, bestDice] = watershedSegmentation(filteredVolume, model_params)
    % Watershed segmentation function that operates slice-by-slice in 2D
    % and unifies preprocessing, marker generation, and post-processing.
    %
    % Input:
    % - volume: 3D MRI/CT volume (preprocessed or raw)
    % - trueMask: Ground truth mask for calculating Dice coefficient
    % - minimaDepthRange: Range of minimaDepth values to search for optimal segmentation
    % - smallObjectsThreshold: (INT) value for "bwareaopen" to remove small
    %                           objects during segmentation
    % - show_slice: (boolean) show central slice true mask / enchanted
    %               image / predicted mask
    % - verbose: (boolean) if true show all optimalMinimaDepth search steps
    % Output:
    % - segmentedVolume: Binary segmented 3D mask
    % - optimalMinimaDepth: Best minimaDepth value based on Dice coefficient
    % - bestDice: Best Dice coeff value
    % Validate required inputs
    if nargin < 2
        error("The algorithm needs at least volume and trueMask to be executed.");
    end
    % Check if model_params exists, if not, initialize it as an empty struct
    if ~exist('model_params','var') || isempty(model_params)
        model_params = struct();
    end
    % Set trueMask if used: in train will be used to optimize minimaDepth
    if isfield(model_params, 'trueMask') &&  model_params.train_mode
        trueMask = model_params.trueMask;
    end 
    model_params = init_watershed(model_params);

    if model_params.binarize &&  model_params.train_mode % remove grey region if present
        trueMask = double(trueMask);    
        %% Compute global minimum and maximum across the 3D volume
        mVal = min(trueMask(:));
        MVal = max(trueMask(:));
        trueMask = (trueMask - mVal) / (MVal - mVal);
        trueMask = trueMask > 0.90;
        trueMask = logical(trueMask);
    end
    if model_params.train_mode % apply train process
        [segmentedVolume, optimalMinimaDepth, bestDice] = watershedTrainer(filteredVolume, trueMask, model_params.minimaDepthRange, ...
            model_params.smallObjectsThreshold, model_params.show_slice, model_params.verbose);
    else % TEST MODE
        % Set default for binarize if not provided
        if ~isfield(model_params, 'depth')
            model_params.depth = 0.25;
        end  
        if ~isfield(model_params, 'heuristic_params')
            error("Insert heuristic params for the function: \nFollow 'sliceWiseTumourHeu.m' params " + ...
                "but insert in model_params.heuristic_params. \nEXAMPLE: model_params.heuristic_params.PARAM#NAME = #VALUE")
        end 
        [segmentedVolume, optimalMinimaDepth, bestDice] = watershedTester(filteredVolume, model_params.depth, model_params.smallObjectsThreshold, ...
            model_params.show_slice, model_params.heuristic_params);

    end
end

% ##################### init parameter
function [model_params] = init_watershed(model_params)
    % Set default for minimaDepthRange if not provided
    if ~isfield(model_params, 'minimaDepthRange')
        model_params.minimaDepthRange = linspace(0.01, 0.2, 10); % Default range for minimaDepth
    end   
    % Set default for smallObjectsThreshold if not provided
    if ~isfield(model_params, 'smallObjectsThreshold')
        model_params.smallObjectsThreshold = 50; % Default for smallObjectsThreshold
    end
    % Set default for binarize if not provided
    if ~isfield(model_params, 'binarize')
        model_params.binarize = true;
    end  
    % Set default for show_slice if not provided
    if ~isfield(model_params, 'show_slice')
        model_params.show_slice = false;
    end
    % Set default for verbose if not provided
    if ~isfield(model_params, 'verbose')
        model_params.verbose = false;
    end  
    % Set default for train_mode if not provided
    if ~isfield(model_params, 'train_mode')
        model_params.train_mode = true;
    end
end

% ############################ TRAINER only function
function [segmentedVolume, optimalMinimaDepth, bestDice] = watershedTrainer(filteredVolume, trueMask, minimaDepthRange, smallObjectsThreshold, show_slice, verbose)
% Initialize variables
    numSlices = size(filteredVolume, 3);
    bestDice = 0;
    optimalMinimaDepth = minimaDepthRange(1);
    segmentedVolume = false(size(filteredVolume)); % Initialize the final segmented volume
    mosaicWatershed = zeros(size(filteredVolume,1), size(filteredVolume,2), numSlices, 3, 'uint8');
    % Enhance contrast slice-by-slice
    enhancedVolume = zeros(size(filteredVolume));
    for i = 1:numSlices
        enhancedVolume(:, :, i) = adapthisteq(filteredVolume(:, :, i));
    end

    % Optimize minimaDepth
    for depth = minimaDepthRange
        % Initialize segmented mask for the current depth
        tempSegmentedVolume = false(size(enhancedVolume));

        % Process each slice
        for i = 1:numSlices
            slice = enhancedVolume(:, :, i); % Current slice
            trueSlice = trueMask(:, :, i); % Ground truth for current slice

            % Compute gradient magnitude
            gradientSlice = imgradient(slice); % gradient magnitude

            % Marker-controlled watershed
            markers = imextendedmin(slice, depth); % Generate markers
            imposedGradient = imimposemin(gradientSlice, markers); % Impose markers
            watershedLabeled = watershed(imposedGradient); % Apply watershed

            if show_slice == true % save for plot
                coloredLabels = label2rgb(watershedLabeled, 'jet', 'w', 'shuffle');
                mosaicWatershed(:, :, i, :) = coloredLabels; % for visualization
            end

            % Extract the tumor region
            uniqueLabels = unique(watershedLabeled(:));
            bestLabel = 0;
            maxOverlap = 0;

            for label = uniqueLabels'
                overlap = sum((watershedLabeled == label) & trueSlice, 'all');
                if overlap > maxOverlap
                    maxOverlap = overlap;
                    bestLabel = label;
                end
            end

            % Create binary mask for the tumor region
            tempSegmentedVolume(:, :, i) = (watershedLabeled == bestLabel);
        end

        if show_slice == true % save for the plot
            watershedLabledVolume = tempSegmentedVolume;
        end

        % Post-processing: Fill holes and remove small objects
        tempSegmentedVolume = imfill(tempSegmentedVolume, 'holes'); % Fill holes
        tempSegmentedVolume = bwareaopen(tempSegmentedVolume, smallObjectsThreshold); % Remove small regions
    
        % Calculate Dice coefficient for the entire volume in training mode
        diceCoeff = calculateDice(trueMask, tempSegmentedVolume);
        % Update best parameters if Dice improves
        if diceCoeff > bestDice
            bestDice = diceCoeff;
            optimalMinimaDepth = depth;
            segmentedVolume = tempSegmentedVolume; % Save the best segmentation
        end
        if verbose == true
            fprintf("MinimaDepth: %.2f, Dice Coefficient: %.4f\n", depth, diceCoeff);
        end
    end
    
    fprintf("Optimal MinimaDepth: %.2f, Best Dice Coefficient: %.4f\n", optimalMinimaDepth, bestDice);

    if show_slice == true
        plotter(trueMask, filteredVolume, segmentedVolume, enhancedVolume, ...
    watershedLabledVolume, mosaicWatershed)
    end
end

% ######################## TEST FUNCTION
function [tempSegmentedVolume, depth, dummy] = watershedTester(filteredVolume, depth, ...
    smallObjectsThreshold, show_slice, heuristic_params)

    numSlices = size(filteredVolume, 3);
    mosaicWatershed = zeros(size(filteredVolume,1), size(filteredVolume,2), numSlices);
    % Enhance contrast slice-by-slice
    enhancedVolume = zeros(size(filteredVolume));
    for i = 1:numSlices
        enhancedVolume(:, :, i) = adapthisteq(filteredVolume(:, :, i));
    end
    % Process each slice
    for i = 1:numSlices
        slice = enhancedVolume(:, :, i); % Current slice

        % Compute gradient magnitude
        gradientSlice = imgradient(slice); % gradient magnitude

        % Marker-controlled watershed
        markers = imextendedmin(slice, depth); % Generate markers
        imposedGradient = imimposemin(gradientSlice, markers); % Impose markers
        watershedLabeled = watershed(imposedGradient); % Apply watershed
        
        % ############################################
        % Fill the boundaries in the watershed output:
        mask = (watershedLabeled > 0);            % Logical mask of non-boundary pixels
        [~, idx] = bwdist(mask, 'euclidean');      % For each pixel, get the index of its nearest nonzero neighbor
        watershedLabeled_filled = watershedLabeled;
        watershedLabeled_filled(~mask) = watershedLabeled(idx(~mask));  % Replace boundary pixels
        %every pixel that was a boundary (false values) gets replaced by 
        % the value of its nearest neighbor, which is part of a cluster.
        
        % SAVE THE GREYSCALE MOSAIC FOR HEURISTIC
        % Instead of using label2rgb to get an RGB image 
        % store the grayscale image for heuristic prediction
        grayLabels = im2uint8(mat2gray(watershedLabeled_filled));
        mosaicWatershed(:, :, i) = grayLabels;  
    end

    % Create binary mask for the tumor region using the heuristic function
    tempSegmentedVolume = sliceWiseTumourHeu(mosaicWatershed, filteredVolume, heuristic_params);

    % Post-processing: Fill holes and remove small objects
    tempSegmentedVolume = imfill(tempSegmentedVolume, 'holes'); % Fill holes
    tempSegmentedVolume = bwareaopen(tempSegmentedVolume, smallObjectsThreshold); % Remove small regions

    if show_slice
        centralSliceIndex = round(size(filteredVolume, 3) / 2);
        enhancedVolumeSlice = squeeze(enhancedVolume(:, :, centralSliceIndex));
        mosaicWatershedSlice = squeeze(mosaicWatershed(:, :, centralSliceIndex));
        predictedSlice = squeeze(tempSegmentedVolume(:, :, centralSliceIndex));
        figure
        subplot(1, 3, 1);
        imshow(enhancedVolumeSlice, []);
        title('Enchanted');
    
        subplot(1, 3, 2);
        imshow(mosaicWatershedSlice, []);
        title('Watershed mosaic');
    
        subplot(1, 3, 3);
        imshow(predictedSlice, []);
        title('Predicted');
        disp('Click on blank space of last figure to continue...');
        waitforbuttonpress; % Wait for mouse click
        disp('Resuming algorithm...');
        close all
    end
    dummy = 'None';
end

% ######################## plot graphs
function [] = plotter(trueMask, filteredVolume, segmentedVolume, enhancedVolume, ...
    watershedLabledVolume, mosaicWatershed)
    % Final visualization with the best parameter
    figure;
    centralSliceIndex = round(size(filteredVolume, 3) / 2);
    trueSlice = squeeze(trueMask(:, :, centralSliceIndex));
    mosaicWatershedSlice = squeeze(mosaicWatershed(:, :, centralSliceIndex, :));
    enhancedVolumeSlice = squeeze(enhancedVolume(:, :, centralSliceIndex));
    watershedLabeledSlice = squeeze(watershedLabledVolume(:, :, centralSliceIndex));  
    predictedSlice = squeeze(segmentedVolume(:, :, centralSliceIndex));

    subplot(1, 5, 1);
    imshow(trueSlice, []);
    title('True Mask');

    subplot(1, 5, 2);
    imshow(enhancedVolumeSlice, []);
    title('Enchanted');

    subplot(1, 5, 3);
    imshow(uint8(mosaicWatershedSlice), []);
    title('Watershed mosaic');

    subplot(1, 5, 4);
    imshow(watershedLabeledSlice, []);
    title('Watershed');

    subplot(1, 5, 5);
    imshow(predictedSlice, []);
    title('Predicted');

    disp('Click on blank space of last figure to continue...');
    waitforbuttonpress; % Wait for mouse click
    disp('Resuming algorithm...');
    close all
end


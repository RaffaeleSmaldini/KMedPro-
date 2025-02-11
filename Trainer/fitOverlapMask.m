function [bestFit, bestLabel] = fitOverlapMask(trueMask, predictedMask)
    % Given the trueMask and a predicted one, define the region of max
    % overlap, excluding the background, to retrieve the tumor label and 
    % generate the binary mask for volume.

    [rows, cols, nz] = size(trueMask);
    bestFit = zeros(size(trueMask));
    
    % Determine the background value from the corners of the 3D volume
    vortex = [
        predictedMask(1, 1, 1), predictedMask(1, 1, nz), ...
        predictedMask(1, cols, 1), predictedMask(1, cols, nz), ...
        predictedMask(rows, 1, 1), predictedMask(rows, 1, nz), ...
        predictedMask(rows, cols, 1), predictedMask(rows, cols, nz)
    ];
    background = mode(vortex); % Most common value among corners
    
    for i = 1:nz
        % Extract the tumor region
        uniqueLabels = unique(predictedMask(:));
        trueSlice = trueMask(:,:,i);
        predictedSlice = predictedMask(:,:,i);
        
        % Exclude background
        uniqueLabels = uniqueLabels(uniqueLabels ~= background);
        
        bestLabel = 0;
        maxOverlap = 0;
        
        % Find the label with maximum overlap
        for label = uniqueLabels'
            overlap = sum((predictedSlice == label) & trueSlice, 'all');
            if overlap > maxOverlap
                maxOverlap = overlap;
                bestLabel = label;
            end
        end

        % Save best fit
        bestFit(:, :, i) = (predictedSlice == bestLabel);
    end
end

function IoU = calculateIoU(groundTruthMask, predictedMask)
    % computeIoU - Calculates the Intersection over Union (IoU) metric
    % 
    % Inputs:
    %   predictedMask  - Binary matrix representing the predicted segmentation (1 for the region of interest, 0 otherwise)
    %   groundTruthMask - Binary matrix representing the ground truth segmentation (1 for the region of interest, 0 otherwise)
    %
    % Output:
    %   IoU - Intersection over Union metric (scalar)
    
    % Validate input dimensions
    if ~isequal(size(predictedMask), size(groundTruthMask))
        error('The predicted mask and ground truth mask must have the same dimensions.');
    end
    
    % Compute intersection and union
    intersection = sum((predictedMask & groundTruthMask), 'all');
    union = sum((predictedMask | groundTruthMask), 'all');
    
    % Calculate IoU
    if union == 0
        IoU = 0; % Handle the edge case where both masks are empty
    else
        IoU = intersection / union;
    end
end

function [] = showOverlap(trueMask, predictedMask, sliceIndex, show_trueMask)
    if nargin < 3
        sliceIndex = round(size(trueMask, 3) / 2); 
    end
    if nargin < 4
        show_trueMask = false; 
    end
    trueSlice = trueMask(:,:,sliceIndex);
    predictedSlice = predictedMask(:,:,sliceIndex);

    %% Ensure the masks are binary
    % binarize image with a threshold since there is a region of uncertainty
    trueSlice = (trueSlice >= 0.9); 
    if ~isa(predictedSlice, 'logical')
        predictedSlice = imbinarize(predictedSlice);
    end
    
    %% Create an RGB overlay
    [rows, cols, ~] = size(trueSlice);
    baseImage = zeros(rows, cols);
    overlay = zeros(rows, cols, 3, 'uint8');
    
    % Assign colors to the overlay
    % True Positives (Green)
    overlay(:,:,2) = uint8((trueSlice & predictedSlice) * 255);
    
    % False Positives (Blue)
    overlay(:,:,3) = uint8((~trueSlice & predictedSlice) * 255);
    
    % False Negatives (Red)
    overlay(:,:,1) = uint8((trueSlice & ~predictedSlice) * 255);
    
    % Blend the overlay with the original image
    alpha = 0.5; % Transparency factor for overlay
    blended = uint8((1 - alpha) * double(baseImage) + alpha * double(overlay));
    
    %% Display overlay
    if show_trueMask
        figure;
        % Display the trueMask
        subplot(1, 2, 1);
        imshow(trueSlice, []);
        title('true Mask');
        % Display the overlay
        subplot(1, 2, 2);
        imshow(blended);
        title('True Mask vs Predicted Mask Overlay');
    else
        figure;
        imshow(blended);
        title('True Mask vs Predicted Mask Overlay');
    end

end
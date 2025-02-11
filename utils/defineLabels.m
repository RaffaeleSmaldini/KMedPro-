function z = defineLabels(mask)
    % Adaptation of "prepare.m" from:
    % https://github.com/PeppeJerry/BRATS-Image-processing/blob/main/Evaluation/Samples/prepare.m
    % prepareLabels: define the labels of the 3D mask.

    % Takes the value of the corners of the 3D matrix (8 pixels) 
    vortex = [
        mask(1, 1, 1),
        mask(1, 1, end),
        mask(1, end, 1),
        mask(1, end, end),
        mask(end, 1, 1),
        mask(end, 1, end),
        mask(end, end, 1),
        mask(end, end, end),
    ];

    % Most common value among the corners is identified as background 
    background = mode(vortex);

    % Generate the background mask
    background_mask = (mask == background);
    num_classes = max(mask(:));

    % Init vector of adjacent pixels between classes
    boundary_counts = zeros(1, num_classes);

    % 3D convolution filter for finding neighbors
    neighborhood_filter = ones(3, 3, 3);  

    % Excludes the central pixel
    neighborhood_filter(2, 2, 2) = 0;

    % Find the neighboring pixels for each class
    for class = 1:num_classes
        % Skip the background class case
        if class == background
            continue;
        end
    
        % Mask for the current class
        class_mask = (mask == class);
    
        % Find the neighboring pixels between the class and the background
        % by convolving the background mask
        % with the neighbor filter and multiplying it by the class mask
        boundary_with_bg = convn(double(background_mask), neighborhood_filter, 'same') .* class_mask;
        
        % Count neighboring pixels
        boundary_counts(class) = sum(boundary_with_bg(:) > 0);
    end
    
    % Determines the tissue class
    [~, tissue] = max(boundary_counts);

    % Determines the tumour class
    tumour = [1,2,3];
    tumour(ismember(tumour, [tissue, background])) = [];

    % tumour = 1 | otherwise = 0
    z = zeros(size(mask));
    z(ismember(mask, tumour)) = 1;
end
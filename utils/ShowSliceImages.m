function ShowSliceImages(imageArray, descriptions, sliceIndex)
%   Creates a subplot of images with descriptions.
%   imageArray: Cell array of images (e.g., {img1, img2, ..., imgN}).
%   descriptions: Cell array of strings describing each image.
%   sliceIndex: slice index to show -> extract a 2D image 
%   The function assumes imageArray and descriptions have the same length.

    % Input validation
    if ~iscell(imageArray) || ~iscell(descriptions)
        error('Both imageArray and descriptions must be cell arrays.');
    end
    if length(imageArray) ~= length(descriptions)
        error('The number of images must match the number of descriptions.');
    end

    numImages = length(imageArray); % Total number of images
    
    % Determine subplot grid size
    numCols = ceil(sqrt(numImages));
    numRows = ceil(numImages / numCols);
    
    % Create the figure
    figure('Name', 'Image Subplot', 'NumberTitle', 'off');
    
    % Loop through images and descriptions
    for i = 1:numImages
        % Add subplot for each image
        subplot(numRows, numCols, i);
        image = imageArray{i};
        dims = size(image);
        if sliceIndex > dims(3)
            sliceIndex = dims(3); % if exceed set to max
        end
        imshow(image(:, :, sliceIndex)); % Display image
        title(descriptions{i}, 'Interpreter', 'none'); % Add title
    end
    
    % Adjust figure layout for better appearance
    sgtitle(sprintf('Images Array Subplots Slice: %d',sliceIndex)); % Add a super title
    set(gcf, 'Color', 'white'); % Set figure background to white
end

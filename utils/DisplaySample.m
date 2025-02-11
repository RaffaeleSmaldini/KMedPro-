function [] = DisplaySample(Data, trainingIndex, sliceIndex)
% -------- Print an example picture -------- % 
    % Display a 2D slice from a 4D image in the training set
    % Index of the training data to visualize
    % Select time point (if applicable)
    % Select slice index (adjust based on dataset)
    
    %% Extract 4D image

    % Takes for a certain traning data a picture and the relative label 
    image4D = Data.training(trainingIndex).image;
    mask4D = Data.training(trainingIndex).label;

    % Check dimensions
    dims = size(image4D);
    mask_dims = size(mask4D);
    fprintf('Image dimensions: %s\n', mat2str(dims));
    fprintf('Mask dimensions: %s\n', mat2str(mask_dims));

    % Check on the slice index of the picture, since each pictures have
    % different sliceIndex
    if ndims(image4D) == 4 && dims(4) >= 2
        if sliceIndex > dims(3)
            sliceIndex = dims(3); % if exceed set to max
        end
        
        % Get traning sample, an highlights on the tumor regione and the
        % mask: 
        imageSlice = image4D(:, :, sliceIndex, 1);  % Sample image
        imageLocalSlice = image4D(:, :, sliceIndex, 2);  % Tumor Region
        maskSlice = mask4D(:, :, sliceIndex, 1);   % Tumor mask
    else
        error(['Unexpected image dimensions or insufficient time points.' ...
            ' Expected 4D image with at least 2 time points.']);
    end
    
    %% Create a subplot to display all three images
    figure;
    
    % Display the sample image
    subplot(1, 3, 1);
    imshow(imageSlice, []);
    colormap('gray');
    title('Sample Image');
    colorbar;

    % Display the tumor region
    subplot(1, 3, 2);
    imshow(imageLocalSlice, []);
    colormap('gray');
    title('Tumor Region');
    colorbar;
    
    % Display the tumor mask
    subplot(1, 3, 3);
    imshow(maskSlice, []);
    colormap('gray');
    title('Tumor Mask');
    colorbar;

    % Add a global title
    sgtitle(sprintf('Training Index %d, Slice %d', trainingIndex, sliceIndex));
   
end









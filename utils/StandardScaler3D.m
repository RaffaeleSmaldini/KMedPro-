function volume = StandardScaler3D(volume)
    % Function to normalize a 3D image
    % The function computes mean and standard deviation of the input image
    % and normalizes it to have zero mean and unit variance.
    %
    % INPUT:
    %   volume - 3D array representing the input image

    % Check if the input is 3D
    if ndims(volume) ~= 3
        error('Input image must be a 3D array.');
    end

    % Compute mean and standard deviation of the image
    img_mean = mean(volume(:));
    img_std = std(volume(:));

    % Handle the case where standard deviation is zero
    if img_std == 0
        warning('Standard deviation is zero. Returning zero matrix.');
        volume = zeros(size(volume));
        return;
    end

    % Normalize the image
    volume = (volume - img_mean) / img_std;
end

function solarized_image = NormalizedSolarize(volume, threshold)
    % NormalizedSolarize applies solarize filter based on threshold to
    % normalized images rage: [0,1] .
    % Inputs:
    %   volume    - A 3D MRI volume (e.g., size [X, Y, Z]) as a numeric array.
    %   threshold - threshold (float) range: [0,1]
    if nargin < 1
        error("The function need at least the volume")
    end
    if nargin < 2
        % Define the default threshold for solarization
        threshold = 0.25;
    else
        if threshold > 1 || threshold < 0
            error("Threshold must be in range [0,1]")
        end
    end

    % Apply solarization
    volume = double(volume);
    % Ensure the volume is in the range [0, 1]
    if max(volume(:)) > 1 || min(volume(:)) < 0
        error('Volume values must be in the range [0, 1]. Check your input.');
    end
    
    % Apply threshold
    mask = volume < threshold; % Pixels below the threshold
    
    % Invert the volume for pixels below the threshold
    im1 = 1 - volume; %  Subtraction for normalized data
    im1 = im1 .* mask; % Apply the mask to invert only selected pixels
    
    % Retain original values for pixels above the threshold
    mask2 = ~mask;      % Complementary mask
    im2 = volume .* mask2;
    
    % Combine both parts
    solarized_image = im1 + im2;

end





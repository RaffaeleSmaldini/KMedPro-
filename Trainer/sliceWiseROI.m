function [mask] = sliceWiseROI(clustered_volume, param)
    %% Slice-wise ROI Masking for 3D Volumes
    % Applies a 2D circular mask to each slice independently
    % Dynamically identifies the background based on corner values
    % INPUT:
    %   clustered_volume: 3D array of segmentation results
    %   param:
        %   base_scaler: Scaling factor for the circular radius [0:1]
        %   use_density_adapt_radius: (bool); true to use density calculation for ROI radius
        %   type: 'log' | 'sigmoid' | 'milder'
            %   if 'log' no param to set
            %   if 'sigmoid':
                %   k: (float) controls the steepness of the sigmoid curve.
                    % Deafult: 2
                %   sigmoid_threshold: determines the center of the transition 
                    % Default: 0.5 -> density range: [0-1]
            %   if 'milder' no params to set
        %   
    % OUTPUT:
    %   mask: 3D masked volume after applying the 2D ROI masks slice-by-slice

    if nargin < 1
        error("The algorithm requires at least the 'clustered_volume' input.");
    end
    if ~isfield(param, 'base_scaler')
        base_scaler = 0.3; % Default radius scaler
    else
        base_scaler = param.base_scaler;
    end
    if isfield(param, 'use_density_adapt_radius') && param.use_density_adapt_radius == true
        use_density_adapt_radius = true;
        values = init_penalizer(param);
    else
       use_density_adapt_radius = false; 
    end
    [rows, cols, slices] = size(clustered_volume);
    mask = zeros(rows, cols, slices);

    % Determine the background value from the corners of the 3D volume
    vortex = [
        clustered_volume(1, 1, 1),
        clustered_volume(1, 1, slices),
        clustered_volume(1, cols, 1),
        clustered_volume(1, cols, slices),
        clustered_volume(rows, 1, 1),
        clustered_volume(rows, 1, slices),
        clustered_volume(rows, cols, 1),
        clustered_volume(rows, cols, slices)
    ];
    background = mode(vortex); % Most common value among corners

    for sliceIndex = 1:slices
        % Create a 2D grid for the current slice
        [X, Y] = meshgrid(1:cols, 1:rows);
        centerX = cols / 2;
        centerY = rows / 2;

        % Extract the current slice
        current_slice = clustered_volume(:, :, sliceIndex);

        % Determine the radius
        if use_density_adapt_radius
            % Calculate density excluding background pixels
            valid_pixels = current_slice(current_slice ~= background);
            density = numel(valid_pixels) / (rows * cols);

            % logarithmic penalty for smoother behavior
            % Smooth reduction for high density but penalize lower
            % densities
            if strcmp(values.type, 'log')
                % Ensures that the penalty saturates for high densities,
                % avoiding overly small circles.
                % Logarithmic growth penalizes low densities more heavily while giving stable behavior for high densities.
                penalty = 1 / (1 + log(1 + density)); 
            elseif strcmp(values.type, 'sigmoid')
                % Ensure smooth transition where penalties saturate for low and high densities
                penalty = 1 - 1 ./ (1 + exp(-values.k * (density - values.sigmoid_threshold)));
            elseif strcmp(values.type, 'milder') 
                % Ensures a slower reduction in penalty as density
                % increases because of sqrt
                penalty = 1 / (1 + sqrt(density));
            end

            % Adjust radius with penalty
            radius = min(rows, cols) * base_scaler * penalty;
        else
            radius = min(rows, cols) * base_scaler;
        end

        % Create the circular mask for this slice
        roi_mask = sqrt((X - centerX).^2 + (Y - centerY).^2) <= radius;

        % Apply the mask
        masked_slice = current_slice;
        masked_slice(~roi_mask) = background; % Replace outside ROI with background value

        % Store the masked slice
        mask(:, :, sliceIndex) = masked_slice;
    end
end

function values = init_penalizer(param)
    if isfield(param, 'type')
        switch param.type
            case 'log'
                values.type = 'log';
            case 'sigmoid'
                values.type = 'sigmoid';
                % penalty = 1 - 1 ./ (1 + exp(-values.k * (density - values.sigmoid_threshold)));
                if ~isfield(param, 'k') 
                % k: controls the steepness of the sigmoid curve
                        values.k = 2;      
                    else
                        values.k = param.k; % set to desidered value
                end
                if ~isfield(param, 'sigmoid_threshold')  
                % sigmoid_threshold: determines the center of the transition (0.5: medium density)
                        values.sigmoid_threshold = 0.5; % default threshold       
                    else
                        values.sigmoid_threshold = param.sigmoid_threshold; % set to desidered value
                end
            case 'milder'
                values.type = 'milder';
            otherwise
                disp("This penalization is non supported. Try: 'log'| 'sigmoid' | 'milder'" + ...
                    "Autoset to 'log'. ")
                values.type = 'log';
        end
    elseif ~isfield(param, 'type') && isfield(param, 'use_density_adapt_radius') && param.use_density_adapt_radius == true
        disp("No penalization set but use_density_adapt_radius is true: " + ...
            "Autoset to 'log'.")
        values.type = 'log'; %set to log for default   
    end
end
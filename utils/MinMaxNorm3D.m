function [mriImage] = MinMaxNorm3D(mriImage)
    %Min-Max Normalization for a 3D MRI image using [0,1] interval
    % INPUT:
    %   mriImage [X, Y, Z] 
    % Convert to double precision
    mriImage = double(mriImage);    
    %% Compute global minimum and maximum across the 3D volume
    mVal = min(mriImage(:));
    MVal = max(mriImage(:));
    mriImage = (mriImage - mVal) / (MVal - mVal);
end
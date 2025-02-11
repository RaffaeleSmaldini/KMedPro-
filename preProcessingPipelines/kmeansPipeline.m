function [volume] = kmeansPipeline(volume)
    % Rescale
    volume = mat2gray(volume); 
    % Normalization
    volume = MinMaxNorm3D(volume);
    
end
function [volume] = watershedPipeline(volume, param)
    %% Rescale intensity for better contrast
    volume = mat2gray(volume);
    %% normalization
    volume = MinMaxNorm3D(volume);
    %% inverse
    volume = Invert(volume);
    %% Anisotropic Filter
    volume = AnisotropicFilter3D(volume, param.anisotropic_iterations, param.anisotropic_gthreshold, false);
    %% Homomorphic Transformation
    volume = HomomorphicFilter3D(volume, param.D0, param.gammaH, param.gammaL);
    %% Sharp Edges
    volume = Sharpen3D(volume);
    %% Log Transform
    volume = LogTransform(volume, param.k); 
end
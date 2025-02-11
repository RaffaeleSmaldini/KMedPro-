function [volume] = otsuPipeline(volume, param)
    %% Rescale intensity for better contrast
    volume = mat2gray(volume); 
    %% Normalization
    volume = MinMaxNorm3D(volume);
    %% PCA 
    volume = PCA3D(volume, param.tau, false); 
    %% Gaussian Filter
    volume = GaussianFilter3D(volume, param.sigma, false); 
    %% Anistropic Filter
    volume = AnisotropicFilter3D(volume, param.anisotropic_iterations, ...
        param.anisotropic_gthreshold, false);
    %% Homomorphic
    volume = HomomorphicFilter3D(volume, param.D0, param.gammaH, param.gammaL);
    volume = LogTransform(volume, param.k, param.N, param.logtype);
end
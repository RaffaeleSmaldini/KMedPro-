function [] = DenoisingMetrics(Oimage, Dimage, nz)    
    %DenoisingMetrics - Perform PSNR and SSIM metric calculation.
    % Inputs:
    %    Oimage - Original 3D MRI volume ([X, Y, Z]) of intensity values.
    %    Dimage - Denoised 3D MRI volume ([X, Y, Z]) of intensity values.
    %    nz - z dimension
    psnr_values = zeros(1, nz);
    ssim_values = zeros(1, nz);
    
    for i = 1:nz
        original_slice = Oimage(:,:,i);
        denoised_slice = Dimage(:,:,i);
        
        % Calcolo PSNR e SSIM
        psnr_values(i) = psnr(denoised_slice, original_slice);
        ssim_values(i) = ssim(denoised_slice, original_slice);
    end
    
    % Output dei risultati
    fprintf('Media PSNR: %.2f dB\n', mean(psnr_values));
    % PSNR measures the ratio between the maximum possible signal power 
    % and the power of the noise that affects the quality of the image.
    % Typical ranges for images:
    %   30–40 dB: High-quality image with little noise.
    %   20–30 dB: Moderate quality with noticeable noise.
    %   < 20 dB: Low quality with significant noise or distortion.
    %If PSNR increases after denoising, the quality of the image has improved.

    fprintf('Media SSIM: %.4f\n', mean(ssim_values));
    %SSIM measures the perceived similarity between two images, focusing
    % on structural information rather than pixel-wise differences
    % SSIM values are in the range [0, 1].
        %1: Perfect similarity (identical images).
        %0: No similarity at all.
    % A higher SSIM indicates better preservation of structural information after denoising.
    
end
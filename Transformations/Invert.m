function volume = Invert(volume)
    % Invert uses imcomplement function to complement the image
    % volume: 3D image - it can also accept 2D images
    % 
    volume = imcomplement(volume);
end
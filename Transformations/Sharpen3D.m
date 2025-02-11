function sharp_volume = Sharpen3D(volume, sharpenStacks)
    %Sharpen3D adaptation for 3D of build-in "imsharpen"
    %volume - A 3D MRI volume (e.g., size [X, Y, Z]) as a numeric array.
    %sharpenStacks - define how many times the function apply sharpen filter.
    if nargin < 1
        error("The function need at least the volume")
    end
    if nargin < 2
        sharpenStacks = 1;
    end
    volume = double(volume);
    [nx, ny, nz] = size(volume); % Dimensions of the 3D volume
    sharp_volume = volume;
    %Apply imsharpen for each slice
    for a=1:sharpenStacks
        for i=1:nz
            sharp_volume(:,:,i) = imsharpen(sharp_volume(:,:,i));
        end
    end
end
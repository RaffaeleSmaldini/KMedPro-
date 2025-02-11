function k = defineDensestSlice(trueMask)
    %defineDensestSlice return k = z index of densest slice
    if nargin < 1
        error("Insert the trueMask for the selected volume")
    end
    k = 0;
    temp = 0;
    [nx, ny, nz] = size(trueMask); % Dimensions of the 3D volume
    for i=1:nz
        white = sum(trueMask(:,:,i)==1, 'all');
        if white > temp
            k = i;
            temp = white;
        end
    end
end
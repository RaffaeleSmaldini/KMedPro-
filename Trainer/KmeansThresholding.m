function [map,clustered] = KmeansThresholding(volume, K)
    dims = size(volume); % save dims for reshaping
    volume = reshape(volume, [], 1); % voxel images
    [map, clustered] = kmeans(volume, K);
    map = reshape(map, dims);
end
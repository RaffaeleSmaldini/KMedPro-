function [map, Otsu_T] = OtsuThreshold(volume, ncluster)
    % OtsuThresholding function performs the otsu thresholding given the
    % volume and number of clusters (thresholds)
    dims = size(volume);
    volume = reshape(volume, [], 1);  
    Otsu_T = multithresh(volume,ncluster);    
    map = imquantize(volume, Otsu_T);  
    map = reshape(map, dims);

end
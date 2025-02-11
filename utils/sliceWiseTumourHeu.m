function [tumorMask] = sliceWiseTumourHeu(segmentedMask, original_volume, params)
    if ~isfield(params, 'weightSpatial')
        params.weightSpatial = 0.3;
    end
    if ~isfield(params, 'nbins')
        params.nbins = 256;
    end
    epsilon = 1e-12; % avoid 0 divisions
    
    % Initialize the tumor mask
    tumorMask = false(size(segmentedMask));
    
    % Compute prostate center in 3D space using nonzero tissue pixels
    roiInd = original_volume > 0;  
    [r_all, c_all, s_all] = ind2sub(size(original_volume), find(roiInd));
    prostateCenter = [mean(r_all), mean(c_all), mean(s_all)];

    [~,~,numSlice] = size(original_volume);

    % Process each slice independently
    for i = 1:numSlice
        originalSlice = original_volume(:,:,i);
        segmentedSlice = segmentedMask(:,:,i);
        
        % Compute background for the current slice using its 4 corners
        vortex_slice = [ ...
            segmentedSlice(1, 1), ...
            segmentedSlice(1, end), ...
            segmentedSlice(end, 1), ...
            segmentedSlice(end, end) ...
        ];
        background_slice = mode(vortex_slice);
        
        % Extract unique clusters for this slice (excluding background)
        clusters = unique(segmentedSlice);
        clusters(clusters == background_slice) = [];

        % Check if there are any clusters left (only background is present)
        if isempty(clusters)
            % No clusters to choose from, so leave tumorMask as false for this slice.
            continue;
        end

        numClusters = numel(clusters);
        
        % Initialize per-slice cluster metrics
        clusterMean = zeros(numClusters,1);
        clusterStd = zeros(numClusters,1);
        clusterEntropy = zeros(numClusters,1);
        clusterCentroidDist = zeros(numClusters,1);

        for k = 1:numClusters
            % Create mask for current cluster
            idx = (segmentedSlice == clusters(k));
            
            % Extract pixel values from the original slice for this cluster
            pixelVals = originalSlice(idx);
            
            % Compute intensity mean
            clusterMean(k) = mean(pixelVals);
            % Compute standard deviation (as a measure of heterogeneity)
            clusterStd(k) = std(pixelVals);
            
            % Compute entropy (texture complexity)
            counts = histcounts(pixelVals, params.nbins);
            p = counts / sum(counts);
            p(p == 0) = [];  % Remove zeros to avoid log(0)
            clusterEntropy(k) = -sum(p .* log2(p));
            
            % Compute distance from cluster centroid to the prostate center
            [r_k, c_k] = ind2sub(size(originalSlice), find(idx));
            clusterCentroid = [mean(r_k), mean(c_k), i];  % Use slice index as the third coordinate
            clusterCentroidDist(k) = norm(clusterCentroid - prostateCenter);
        end

        % Normalize the computed metrics within the current slice
        normMean = (clusterMean - min(clusterMean)) / (max(clusterMean) - min(clusterMean) + epsilon);
        normStd = (clusterStd - min(clusterStd)) / (max(clusterStd) - min(clusterStd) + epsilon);
        normEntropy = (clusterEntropy - min(clusterEntropy)) / (max(clusterEntropy) - min(clusterEntropy) + epsilon);
        normCentroidDist = (clusterCentroidDist - min(clusterCentroidDist)) / (max(clusterCentroidDist) - min(clusterCentroidDist) + epsilon);

        % Compute tumor score:
        %   - Tumor tends to be darker: (1 - normMean)
        %   - More heterogeneous: + normStd
        %   - More complex texture: + normEntropy
        %   - Closer to prostate center: - weightSpatial * normCentroidDist
        tumorScore = (1 - normMean) + normStd + normEntropy - params.weightSpatial * normCentroidDist;
        % tumorScore = - params.weightSpatial * normCentroidDist;
        
        % Choose the cluster with the highest tumor score as the tumor candidate for the slice
        [~, tumorClusterIdx] = max(tumorScore);
        tumorClusterLabel = clusters(tumorClusterIdx);
        % --- DEBUG ---
        % disp("Clusters: "); disp(clusters)
        % disp("Tumor scores: "); disp(tumorScore)
        % -------------
        % Update the tumor mask for the current slice
        tumorMask(:,:,i) = (segmentedSlice == tumorClusterLabel);
    end
end

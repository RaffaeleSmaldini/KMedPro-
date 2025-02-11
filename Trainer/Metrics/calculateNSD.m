function NSD = calculateNSD(x,Y,tau)
    % 
    Y = logical(Y);
    x = logical(x);
    
    % edges extraction
    SA = bwperim(Y);
    SB = bwperim(x);
    
    % kernel
    cube = ones(tau, tau, tau);
    T = strel('arbitrary', cube);

    % boarder region of T,SA and T,SB
    SA_T = imdilate(SA, T);
    SB_T = imdilate(SB, T);
    
    % Boundary outside intersection
    intersectionA = SA & SB_T;
    intersectionB = SB & SA_T;
    
    NSD = (sum(intersectionA(:)) + sum(intersectionB(:))) / (sum(SA(:)) + sum(SB(:)));
end
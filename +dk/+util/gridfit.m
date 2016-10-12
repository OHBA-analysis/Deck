function [h,l] = gridfit( nelem, lhratio )
%
% [h,l] = gridfit( nelem, lhratio=omega )
%
% Return optimal grid size to fit nelem elements with ratio lhratio (default: golden ratio).
%
% JH

    % use golden ratio by default
    if nargin < 2
        lhratio = (1+sqrt(5))/2;
    end
    
    % solve system
    %
    %   l/h = lhratio
    %   h*l >= nelem
    %
    h = ceil(sqrt(nelem/lhratio));
    l = round(h*lhratio);

    % should not happen, but just to be sure
    if h*l < nelem
        l = l+1;
    elseif (h-1)*l >= nelem
        h = h-1;
    end
    
end
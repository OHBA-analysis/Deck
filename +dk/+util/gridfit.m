function [h,l] = gridfit( nelem, lhratio )
%
% [h,l] = gridfit( nelem, lhratio=16/9 )
%
% Return optimal grid size to fit nelem elements with ratio lhratio (default: 16/9).
%
% JH

    % use 16:9 by default
    if nargin < 2
        lhratio = 16/9;
    end
    
    % solve system
    %
    %   l/h = lhratio
    %   h*l >= nelem
    %
    h = ceil(sqrt(nelem/lhratio));
    l = fix(h*lhratio);

    % should not happen, but just to be sure
    if h*l < nelem
        l = l+1;
    elseif (h-1)*l >= nelem
        h = h-1;
    end
    
end
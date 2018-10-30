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
    h = ceil(sqrt( nelem / lhratio ));
    l = ceil(nelem / h);
    %l = fix(h*lhratio);
    
end
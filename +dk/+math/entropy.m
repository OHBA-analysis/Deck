function [Hx,Px] = entropy( x, nbins )
%
% [Hx,Px] = entropy( x, nbins )
%
% Estimate entropy using nbins histogram.
%
% JH

    if nargin < 2, nbins = 100; end

    % Reshape, rescale and bin data
    x = x(:);
    n = numel(x);
    l = min(x);
    x = 1 + floor( nbins*(x - l)/(max(x)-l) );
    m = nbins+1;
    
    % Compute entropy
    Px = accumarray( x, 1, [1,m] )/n;
    Hx = -dot( Px, log2(Px+eps) );

end
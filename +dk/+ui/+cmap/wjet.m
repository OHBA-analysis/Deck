function x = wjet( n )
%
% x = wjet( n=64 )
%
% Matlab jet colormap with whitened middle range.
%
% JH

    if nargin < 1, n=64; end
    
    x = jet(n);
    w = (1:n)/n - 0.5;
    w = 4*w;
    w = 1 - 0.7*exp( - w.^2 );
    x = bsxfun( @power, x, w(:) );
    
end
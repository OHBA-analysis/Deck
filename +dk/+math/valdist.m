function d = valdist(x,n,s)
%
% d = dk.math.valdist(x,n,s)
%
% Compute the value distribution on data x.
% x is the data, considered internally as a single vector x(:).
% n is the number of points for the density estimation (default 121).
% s is the number of standard deviations to consider (default 7).
%
% Output d is a struct with fields
%   x   Standardised values at which the distribution was estimated
%   y   Corresponding distribution estimates
%   m   Sample mean
%   s   Sample std
%
% JH

    if nargin < 3, s = 7; end
    if nargin < 2, n = 121; end
    
    n = floor(n);
    if dk.is.even(n), n = n+1; end
    
    assert( n > 21, 'Number of points (2nd input) too low. Set to > 21.' );
    assert( s >= 3, 'Number of standard deviations (3rd input) too low. Set to >= 3.' );
    
    x = x(:);
    d.m = mean(x);
    d.s = std(x);
    
    sm = max( 0.1, s*d.s );
    [d.y,d.x] = ksdensity( (x-d.m)/max(d.s,eps), linspace(-sm,sm,n) );
    
    if nargout == 0
        plot( d.x, d.y );
        xlabel(sprintf('Standard deviations (s=%g)',d.s));
        ylabel('Density estimate');
    end

end
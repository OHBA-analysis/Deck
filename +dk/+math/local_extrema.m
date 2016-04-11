function [lmin,lmax] = local_extrema( x, inc_endpoints )
%
% [lmin,lmax] = LOCAL_EXTREMA( data )
%
% This function is an extremely fast local extrema finder (returns indices).
% In the case of plateau in the data, the function returns the index of the _first_ point.
%
% Example:
%
%   data = [25 8 15 5 5 10 10 3 1 20 7];
%   dk.math.local_extrema(data);
%
% JH

    if nargin < 2, inc_endpoints = false; end
    assert( isvector(x) && isnumeric(x), 'Input data should be a numeric vector.' );

    x  = x(:);
    dx = diff(x,1,1);
    
    if inc_endpoints
        zc = [dx(1:end-1) .* dx(2:end) <= 0; 1];
        le = [ -dx(1); zc .* dx ];
    else
        zc = [dx(1:end-1) .* dx(2:end) <= 0; 0];
        le = [ 0; zc .* dx ];
    end
    
    lmin = find( le < 0 );
    lmax = find( le > 0 );
    
    if nargout == 0 
        
        figure(); n = numel(x);
        
        plot( 1:n, x ); hold on;
        plot( lmin, x(lmin), 'bo' );
        plot( lmax, x(lmax), 'ro' ); hold off;
        
        title('Showing local maxima');
        legend('Data','Local min','Local max');
        
    end
    
end

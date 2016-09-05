function r = ksreg( x, y, n, b, kerf, doplot )
%
% Kernel Smoothing Regression
%
% Inspired by:
% http://uk.mathworks.com/matlabcentral/fileexchange/19195-kernel-smoothing-regression

    % sort input data
    [x,o] = sort(x(:));
    y = dk.to_col(y(o));
    
    % set a sensible number of points in output
    if nargin < 3 || isempty(n), n = 100; end
    
    % optimal bandwidth suggested by Bowman and Azzalini (1997) p.31
    r.n = numel(x);
    r.a = (4/3/r.n)^0.2 / 0.6745;
    if nargin < 4 || isempty(b)
        hx = median(abs(x-median(x)));
        hy = median(abs(y-median(y)));
        b  = r.a * sqrt( hy * hx );
    end
    r.b = b;
    
    % regression kernel
    if nargin < 5 || isempty(kerf), kerf = 'rat2'; end
    if ischar(kerf)
    switch lower(kerf)
        
        case 'exp1'
            kerf = @(t) exp( -abs(t) );
        case 'exp2'
            kerf = @(t) exp( -t.*t );
        case 'rat1'
            kerf = @(t) 1./(1+abs(t));
        case 'rat2'
            kerf = @(t) 1./(1+t.*t);
        
    end
    end
    
    % check inputs
    assert( isscalar(n) && n > 0, 'n should be positive scalar.' );
    assert( isscalar(b) && b > sqrt(eps)*n, 'b should be a positive scalar, there might not be enough variation in the data.' );
    assert( kerf(1) == kerf(-1), 'ker should be a scalar symmetric function.' );

    r.x = linspace(x(1),x(end),n);
    r.f = zeros(1,n);
    for i = 1:n
        w = kerf( (x - r.x(i))/b );
        r.f(i) = sum(w.*y) / sum(w);
    end

    % plot
    if nargin < 6, doplot = nargout == 0; end
    if doplot
        
        scatter( x, y, 'bo' ); hold on;
        plot( r.x, r.f, 'r-', 'LineWidth', 3 ); hold off;
        title(sprintf( 'Kernel smoothing regression (bw = %g)', b ));
        legend( 'Original data', 'Regression' );
        
    end

end
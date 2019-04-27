function [img,xvals,yvals] = cloud2image( X, w, nrows, ncols, xrange, yrange )
%
% [img,xvals,yvals] = com.ui.cloud2image( X, w, nrows, ncols, xrange, yrange )
%
% Create image from cloud of 2d points, by binning points into pixels.
%
% JH

    assert( dk.is.matrix(X,[0,2]), 'X should be Nx2.' );
    n = size(X,1);
    
    if nargin < 6
        [ymin,ymax] = ant.stat.extrema( X(:,2) );
        yrange      = [ymin,ymax];
    end
    if nargin < 5
        [xmin,xmax] = ant.stat.extrema( X(:,1) );
        xrange      = [xmin,xmax];
    end
    
    if isempty(w), w = 1; end
    if isscalar(w)
        w = w * ones(n,1);
    end
    assert( isvector(w) && numel(w)==n, 'w should match the rows of X.' );
    

    xvals = linspace( xrange(1), xrange(2), ncols );
    yvals = linspace( yrange(1), yrange(2), nrows );
    
    
    dx = diff(xrange)/(ncols-1);
    dy = diff(yrange)/(nrows-1);
    
    x  = 1+round( (X(:,1) - xrange(1)) / dx );
    y  = 1+round( (X(:,2) - yrange(1)) / dy );
    
    xm = x >= 1 & x <= ncols;
    ym = y >= 1 & y <= nrows;
    m  = xm & ym;
    
    img = accumarray( [y(m), x(m)], w(m), [nrows,ncols] );

end
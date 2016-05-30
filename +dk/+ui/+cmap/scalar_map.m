function col = scalar_map( values, cmap )
%
% Assign a color to each element in vector "values" using the colormap cmap.
% cmap should be a nx3 matrix with n typically on the order of 100.

    if nargin < 2, cmap = jet(256); end
    
    values = dk.math.rescale( values );
    
    nc  = size( cmap, 1 );
    col = linspace( 0, 1, nc );
    col = interp1( col(:), cmap, values(:), 'linear' );

end

function ind = mapping( values, index, method )
%
% Assign a color to each element in vector "values" using the colormap cmap.
% cmap should be a nx3 matrix with n typically on the order of 100.

    if nargin < 3, method = 'linear'; end
    
    values = dk.math.rescale( values, [0,1] );
    
    ni  = size( index, 1 );
    ind = linspace( 0, 1, ni );
    ind = interp1( ind(:), index, values(:), method );

end

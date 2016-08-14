function ind = mapping( values, index, method )
%
% Interpolate index in [0,1] as mapping to range of values using method.

    if nargin < 3, method = 'linear'; end
    
    values = dk.math.rescale( values, [0,1] );
    
    ni  = size( index, 1 );
    ind = linspace( 0, 1, ni );
    ind = interp1( ind(:), index, values(:), method );

end

function y = squarepos( x, strict )
    
    y = dk.is.squaremat(x) && isnumeric(x);
    if nargin > 1 && strict
        y = y && all( x(:) > 0 );
    else
        y = y && all( x(:) >= 0 );
    end
    
end
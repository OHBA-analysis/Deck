function y = squarepos( x, strict )

    if nargin < 2, strict=true; end

    y = dk.is.squaremat(x) && isnumeric(x);
    if nargin > 1 && strict
        y = y && all( x(:) > 0 );
    else
        y = y && all( x(:) >= 0 );
    end
    
end
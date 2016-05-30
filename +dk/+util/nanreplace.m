function x = nanreplace( x, val )

    if nargin < 2, val = 0; end
    x(isnan(x)) = val;

end
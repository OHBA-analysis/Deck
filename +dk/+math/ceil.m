function y = ceil( x, n )
%
% Ceil to a given decimal place.

    if nargin < 2
        y = ceil(x);
    else
        y = 10^n;
        y = ceil( y*x ) / y;
    end

end

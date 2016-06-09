function y = floor( x, n )
%
% Floor to a given decimal place.

    if nargin < 2
        y = floor(x);
    else
        y = 10^n;
        y = floor( y*x ) / y;
    end

end

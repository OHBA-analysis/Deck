function y = round( x, n )
%
% Round to a given decimal place (for versions of Matlab < 2015).

    if nargin < 2
        y = round(x);
    else
        y = 10^n;
        y = round( y*x ) / y;
    end

end

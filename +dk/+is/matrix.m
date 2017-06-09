function y = matrix( x, n )
%
% y = dk.is.matrix( x, n=[] )
%
% Check if input is a numeric matrix.
% Optionally check for number of elements or size.
%

    if nargin < 2, n=[]; end

    y = isnumeric(x) && ismatrix(x);
    
    switch numel(n)
        case 1
            y = y && (numel(x) == n);
        case 2
            y = y && all(size(x) == n);
        otherwise
            error('Unexpected input.');
    end

end
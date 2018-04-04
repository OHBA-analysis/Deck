function y = matrix( x, n )
%
% y = dk.is.matrix( x, n=[] )
%
% Check if input is a numeric matrix.
% Optionally check for size:
% - scalar means square
% - otherwise [row,column]
%

    if nargin < 2, n=[]; end

    y = isnumeric(x) && ismatrix(x);
    
    switch numel(n)
        case 0
            % nothing to do
        case {1,2}
            y = y && all(size(x) == n(:)');
        otherwise
            error('Unexpected input.');
    end

end
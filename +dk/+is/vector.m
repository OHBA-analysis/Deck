function y = vector( x, n )
%
% y = vector( x, n )
%
% Check whether input is numeric vector
% Optionally check for number of elements or shape
%

    y = isnumeric(x) && isvector(x);
    if nargin > 1
        switch n
            case {'row','r','horz'}
                y = y && size(y,1)==1;
            case {'col','c','vert'}
                y = y && size(y,2)==1;
            otherwise
                y = y && numel(x)==n;
        end
    end
    
end
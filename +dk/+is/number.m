function y = number(varargin)
    y = dk.mapfun( @(x) isnumeric(x) && isscalar(x), varargin, true );
end
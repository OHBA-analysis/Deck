function y = number(varargin)
    y = dk.cellfun( @(x) isnumeric(x) && isscalar(x), varargin, true );
end
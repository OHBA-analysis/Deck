function y = number(varargin)
    y = cellfun( @(x) isnumeric(x) && isscalar(x), varargin, 'UniformOutput', true );
end
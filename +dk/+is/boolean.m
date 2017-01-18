function y = boolean(varargin)
    y = cellfun( @(x) islogical(x) && isscalar(x), varargin, 'UniformOutput', true );
end
function y = squaremat( varargin )
% square matrix
    y = cellfun( @(x) ismatrix(x) && diff(size(x))==0, varargin, 'UniformOutput', true );
end
function y = integer(varargin)
    y = dk.is.number(varargin{:}) & cellfun( @(x) mod(x,1)==0, varargin, 'UniformOutput', true );
end
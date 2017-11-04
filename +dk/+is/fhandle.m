function y = fhandle(varargin)
    y = dk.mapfun( @(x) isa(x,'function_handle'), varargin, true );
end
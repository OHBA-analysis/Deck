function y = fhandle(varargin)
    y = dk.cellfun( @(x) isa(x,'function_handle'), varargin, true );
end
function wassert( condition, fmt, varargin )
    if dk.verbosity([],true)>=2 && ~all(logical(condition))
        warning( fmt, varargin{:} );
    end
end

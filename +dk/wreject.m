function wreject( condition, fmt, varargin )
    if dk.verbosity([],true)>=2 && any(logical(condition))
        warning( fmt, varargin{:} );
    end
end

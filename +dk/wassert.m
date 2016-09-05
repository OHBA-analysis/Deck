function wassert( condition, fmt, varargin )
    if dk.verb.get(true) >= dk.verb.get('warning') && ~all(logical(condition))
        warning( fmt, varargin{:} );
    end
end

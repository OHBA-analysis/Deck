function wreject( condition, fmt, varargin )
    if dk.verb.get(true) >= dk.verb.get('warning') && any(logical(condition))
        warning( fmt, varargin{:} );
    end
end

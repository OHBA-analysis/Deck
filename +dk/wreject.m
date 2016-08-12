function wreject( condition, fmt, varargin )
    if any(logical(condition))
        warning( fmt, varargin{:} );
    end
end

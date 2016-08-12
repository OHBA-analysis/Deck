function wassert( condition, fmt, varargin )
    if ~all(logical(condition))
        warning( fmt, varargin{:} );
    end
end

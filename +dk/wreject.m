function wreject( condition, fmt, varargin )
    if (condition)
        warning( fmt, varargin{:} );
    end
end

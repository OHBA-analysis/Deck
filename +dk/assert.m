function assert( condition, fmt, varargin )
    assert( all(logical(condition)), sprintf(fmt,varargin{:}) );
end

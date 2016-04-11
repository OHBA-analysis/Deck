function assert( condition, fmt, varargin )
    assert( condition, sprintf(fmt,varargin{:}) );
end

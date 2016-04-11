function reject( condition, fmt, varargin )
    assert( ~condition, sprintf(fmt,varargin{:}) );
end

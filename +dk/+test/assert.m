function assert( condition, success, varargin )

    if all(logical(condition))
        dk.println(success);
    else
        error( varargin{:} );
    end

end
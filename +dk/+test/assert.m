function assert( condition, success, varargin )

    if all(logical(condition))
        dk.disp(success);
    else
        error( varargin{:} );
    end

end

function reject( condition, success, varargin )

    if ~any(logical(condition))
        dk.println(success);
    else
        error( varargin{:} );
    end

end
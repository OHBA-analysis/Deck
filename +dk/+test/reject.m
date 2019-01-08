function reject( condition, success, varargin )

    if ~any(logical(condition))
        dk.disp(success);
    else
        error( varargin{:} );
    end

end

function varargout = trywait( ntry, twait, fhandle, msg )
%
% varargout = trywait( ntry, twait, fhandle, msg='Failed attempt.' )
% 
% Try to run function handle at most ntry times, and wait twait seconds in case of error.
% A message can be provided to be displayed in case of failure.
%
% The error message is displayed as a warning at each failed trial.
% After ntry attempts have failed, an error is thrown.
% 
% JH

    if nargin < 4, msg = 'Failed attempt.'; end

    while ntry > 0
        
        ntry = ntry - 1;
        try
            if nargout > 0
                [varargout{:}] = fhandle();
            else
                fhandle();
            end
            ntry = 0;

        catch err

            dk.warn( '%s\nError message: %s', msg, err.message );
            assert( ntry > 0, 'Too many failed attempts, aborting.' );

            dk.println( 'Wait %d second(s) and retry (%d attempt(s) left).', twait, ntry );
            pause(twait);
        end
        
    end
    
end
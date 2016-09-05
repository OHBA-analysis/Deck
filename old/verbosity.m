function [v,n] = verbosity( level, quiet )
%
% Set verbosity level affecting the following functions:
%   dk.wassert, dk.wreject
%   dk.println
%   dk.warn
%   dk.info
%   dk.debug
%
% Verbosity levels are:
%   1 quiet
%   2 warning
%   3 info
%   4 debug
%
% Default is:
%   3 info
%
% JH

    if nargin < 2, quiet = false; end

    NAME    = 'MATLAB_DECK_VERBOSITY';
    DEFAULT = 3;
    LEVELS  = {'quiet','warning','info','debug'};

    % no input, show status
    if nargin < 1 || isempty(level)
        
        % read environment variable
        v = deblank(getenv(NAME));
        if isempty(v)
            v = dk.verbosity(DEFAULT,true);
        else
            v = str2double(v);
        end
        n = LEVELS{v};
        
        % show message
        if ~quiet
            dk.println( '[dk.verbosity] Currently set to "%s".', n );
        end
        
    else
        
        % parse input
        if ischar(level)
            [~,v] = ismember( level, LEVELS );
        elseif isnumeric(level)
            v = level;
        else
            error('Bad level type.');
        end
        
        % set environment variable
        try
            n = LEVELS{v};
            setenv( NAME, num2str(v) );
        catch
            error('Bad level value.');
        end
        
        % show message
        if ~quiet
            dk.println( '[dk.verbosity] Setting verbosity to "%s".', n );
        end
        
    end

end

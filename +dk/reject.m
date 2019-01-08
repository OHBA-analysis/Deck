function success = reject( varargin )
%
% success = dk.reject( condition, fmt, varargin )
% success = dk.reject( channel, condition, fmt, varargin )
%
% Default channel is 'error'.
% Returns true if the rejection passes, false otherwise.
%
% JH

    validE = {'e', 'err', 'error'};
    validW = {'w', 'warn', 'warning'};
    validI = {'i', 'info'};
    validD = {'d', 'dbg','debug'};

    arg1 = varargin{1};
    if ischar(arg1) && ismember(lower(arg1),[validE validW validI validD])
        chan = lower(arg1);
        cond = varargin{2};
        args = varargin(3:end);
    else
        chan = 'err';
        cond = arg1;
        args = varargin(2:end);
    end
    success = ~any(logical(cond));

    log = dk.logger.default();
    depth = log.stdepth;
    if ~success
        log.write( chan, depth, args{:} );
    end
    
end

function success = reject( varargin )
%
% success = dk.reject( condition, fmt, varargin )
% success = dk.reject( channel, condition, fmt, varargin )
%
% Default channel is 'error'.
% Returns true if the rejection passes, false otherwise.
%
% Available channels are:
%   e,err,error
%   w,warn,warning
%   i,info
%   d,dbg,debug
%
% JH

    success = dk.logger.default().reject(varargin{:});
    
end

function success = assert( varargin )
%
% success = dk.assert( condition, fmt, varargin )
% success = dk.assert( channel, condition, fmt, varargin )
%
% Default channel is 'error'.
% Returns true if the assertion passes, false otherwise.
%
% Available channels are:
%   e,err,error
%   w,warn,warning
%   i,info
%   d,dbg,debug
%
% JH

    success = dk.logger.default().assert(varargin{:});
    
end

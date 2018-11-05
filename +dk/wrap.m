function out = wrap(varargin)
%
% out = wrap(varargin)
%
% Make a scalar cell from inputs.
% This is simply:
%   out = {dk.unwrap( varargin{:} )}
%
% JH

    out = {dk.unwrap(varargin{:})};
end
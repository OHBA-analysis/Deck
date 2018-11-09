function out = wrap(varargin)
%
% out = wrap(varargin)
%
% Make a scalar cell from inputs.
% This is simply:
%   out = {dk.unwrap( varargin{:} )}
%
% JH

    out = varargin;
    while numel(out)==1 && iscell(out{1})
        out = out{1};
    end
    
end
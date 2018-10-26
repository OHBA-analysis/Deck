function out = unwrap(varargin)
%
% out = unwrap(varargin)
%
% Extract value from input cell.
%
% JH

    out = varargin;
    while iscell(out) && numel(out)==1
        out = out{1};
    end
    
end
function y = string(varargin)
%
% Check whether inputs are strings (row of chars).
%

    y = dk.mapfun( @(x) ischar(x) & isrow(x), varargin, true );
end
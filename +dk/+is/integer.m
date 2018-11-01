function y = integer(varargin)
%
% y = integer( x )
% y = integer( x1, x2, ... )
%
% Check if inputs are integers.
% If input is numeric array, then return logical array of the same size (element-wise).
% Otherwise, return scalar false.
%
% JH

    y = dk.is.number(varargin{:}) & dk.mapfun( @(x) dk.num.modeq(x,1,0), varargin, true );
    
end

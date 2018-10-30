function y = integer(varargin)
%
% y = integer( x )
% y = integer( x1, x2, ... )
%
% Check if input is an integer.
% If several inputs, return a vector.
%

    %y = dk.is.number(x) && (mod(x,1) == 0);
    y = dk.is.number(varargin{:}) & dk.mapfun( @(x) dk.num.modeq(x,1,0), varargin, true );
    
end

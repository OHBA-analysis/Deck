function y = even(varargin)
%
% y = even(x)
% y = even( x1, x2, ... )
%
% Check if input(s) is/are even integers.
%

    y = dk.mapfun( @(x) dk.num.modeq(x,2,0), varargin, true );
end

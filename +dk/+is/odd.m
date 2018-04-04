function y = odd(varargin)
%
% y = odd(x)
% y = odd(x1, x2, ...)
%
% Check if input is odd.

    y = dk.mapfun( @(x) dk.priv.modtest(x,2,1), varargin, true );
end
function [m,t] = ormag( val, n )
%
% [m,t] = dk.util.ormag( val, n=1 )
%
% Order of magnitude.
% First ouput is the exponent corresponding to the most significant digit.
% Second output is the base10 rounding threshold to retain n digits of the input.
%
% Example:
%
%   x = 12.345678;
%   [m,t] = dk.util.ormag(x,3)
%   assert( abs( x - t*round(x/t) ) < t )
%
% JH

    if nargin < 2, n=1; end

    % highest significant digit
    m = floor(log10(val));
    
    % remove n from that
    t = 10^(m-n);

end
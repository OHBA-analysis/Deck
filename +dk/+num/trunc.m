function y = trunc( x, n )
%
% y = dk.num.trunc( x, n )
%
% Note that this function probably doesn't do what you expect; use dk.num.floor
% to truncate to n decimal places.
%
% This function truncates input x to n significant digits away from 0.
%
% JH
    
    y = max( abs(x), eps );
    y = 10.^( -floor(log10(y)) + n-1 );
    y = sign(x) .* ceil( abs(x) .* y ) ./ y;
    
end
function y = trunc( x, s )
%
% y = trunc( x, s )
%
% Truncate input to s signficant digits away from 0.
%
% JH
    
    y = max( abs(x), eps );
    y = 10.^( -floor(log10(y)) + s-1 );
    y = sign(x) .* ceil ( abs(x) .* y ) ./ y;
    
end
function y = truncate( x, s )
%
% Truncate input to s signficant digits away from 0.
    
    y = max( abs(x), eps );
    y = 10.^( -floor(log10(y)) + s-1 );
    y = sign(x) .* ceil ( abs(x) .* y ) ./ y;
    
end
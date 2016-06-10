function z = sample( x, y, n )
%
% z = sample( x, y, n )
%
% Sample n realisations of 1-d distribution y defined at points x.
%
% JH

    x = [x(:); x(1)];
    y = cumsum(y(:));
    y = [0; y] / y(end);
    
    u = rand(n,1);
    k = dk.math.upper_bound( y, u );
    k = k(:);
    
    w = (u - y(k-1)) ./ max( y(k)-y(k-1), eps );
    z = (1-w) .* x(k-1) + w .* x(k);
    
end
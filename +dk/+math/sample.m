function z = sample( x, y, n )
%
% z = sample( x, y, n )
%
% Sample n realisations of 1-d distribution y defined at points x.
%
% JH

    y = cumsum(y);
    a = y(1);
    b = y(end);
    
    q = linspace(a,b,numel(x));
    z = interp1( y, x, q, 'pchip' );
    z = interp1( q, z, a + (b-a)*rand(1,n), 'pchip' );
    
end
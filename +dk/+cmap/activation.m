function c = activation( n, signed, g ) 
%
% c = activation( n=64, signed=false, g=0.5 ) 
%
% Simple gray to red colormap.
% In the signed case, red to gray for negative parts.
% Third input controls how dark the 0-gray is (0: black, 1: white).
%

    if nargin < 3, g=0.5; end
    if nargin < 2, signed=false; end
    if nargin < 1, n=64; end

    r = hsv2rgb([0,.9,.8]);
    b = hsv2rgb([.6,.9,.8]);
    g = g*[1,1,1];
    
    if signed
        if mod(n,2)==0, n=n+1; end
        c = [ -1, b; 0, g; 1, r ];
        x = linspace(-1,1,n)';
    else
        c = [ 0, g; 1, r ];
        x = linspace(0,1,n)';
    end
    c = interp1( c(:,1), c(:,2:4), x, 'linear' );
    
end
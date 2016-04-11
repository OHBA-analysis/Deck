function c = tap( n, signed )
%
% c = tap( n=64, signed=false )
%
% Tap colormap.
%   n is the desired number of colors (default: 64).
%   signed can be set to true if caxis is symmetric & centered at 0.
%   

    if nargin < 1, n = 64; end
    if nargin < 2, signed = false; end
    
    method = 'pchip';

    if signed
        C = [ ...
            -1.0, 0.0, 0.1, 1.0; ...
            -0.0, 0.9, 0.9, 0.9; ...
            +1.0, 1.0, 0.1, 0.0  ...
        ];
        x = linspace(-1,1,n)';
    else
        C = [ ...
            -0.0, 0.9, 0.9, 0.9; ...
            +1.0, 1.0, 0.1, 0.0  ...
        ];
        x = linspace(0,1,n)';
    end

    c = interp1( C(:,1), C(:,2:4), x, method );

end

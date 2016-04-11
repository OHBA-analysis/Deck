function [nx,ny,res] = imresample( x, y, img, nx, ny, method )

    if nargin < 6, method = 'linear'; end

    [gx,gy] = meshgrid( x, y );
    nx      = linspace( x(1), x(end), nx );
    ny      = linspace( y(1), y(end), ny );
    [ix,iy] = meshgrid( nx, ny );
    res     = interp2( gx, gy, img, ix, iy, method );

end

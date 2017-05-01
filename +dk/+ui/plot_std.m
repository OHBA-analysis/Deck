function [ph,fh] = plot_std( x, y, yd, popts, fopts )
% [ph,fh] = plot_std( x, y, yd, popts, fopts )
%
% Mean-deviation plot.
% Plot the curve (x,y) on top of a background surface spanning (y-yd,y+yd).
%
% Required: x, y, yd (same size vectors)
% Optional: popts, fopts (cell of parameters forwarded to plot and fill, respectively)
%
% yd can also be nx2 or 2xn, in which case it specifies the lower and upper bound of the surface.
%
% Example:
%   x  = linspace( 0, 2*pi, 100 ); 
%   y  = sin(x); 
%   yd = .05 + abs(y)/10; 
%   dk.ui.plot_std(x,y,yd);
%
% JH


    color_blue = lab2rgb([60 -5 -30]);
    color_red  = lab2rgb([60 45  20]);
    
    if nargin < 4
        popts = {'LineWidth',1.5,'Color',color_blue};
    end
    if nargin < 5
        fopts = {'LineWidth',1,'EdgeColor',color_red,'FaceAlpha',0.6};
    end

    n = numel(x);
    assert( numel(y)==n, 'y size mismatch.' );
    x = x(:); y = y(:);
    
    if numel(yd) == 2*n
        assert( ismatrix(yd) && any(size(yd)==2), 'yd should be 2xn or nx2.' );
        if size(yd,1)==2, yd = yd'; end % make it nx2
    else
        assert( numel(yd)==n, 'yd size mismatch.' );
        yd = yd(:);
        assert( all(yd >= 0), 'Deviations should be positive.' );
        yd = [y-yd,y+yd];
    end
    
    fh = fill( vertcat(x,flipud(x)), vertcat(yd(:,1),flipud(yd(:,2))), color_red, fopts{:} ); hold on;
    ph = plot( x, y, popts{:} ); hold off;

end

function [ph,fh] = plot_std( x, y, yd, popts, fopts )
% [ph,fh] = plot_std( x, y, yd, popts, fopts )
%
% Mean-deviation plot.
% Plot the curve (x,y) on top of a background surface spanning (y-yd,y+yd).
%
% Required: x, y, yd (same size vectors)
% Optional: popts, fopts (cell)
%
% Example:
%   x  = linspace( 0, 2*pi, 100 ); 
%   y  = sin(x); 
%   yd = .05 + abs(y)/10; 
%   dk.ui.plot_std(x,y,yd);
%
% Contact: jhadida [at] fmrib.ox.ac.uk


    color_blue = lab2rgb([60 -5 -30]);
    color_red  = lab2rgb([60 45  20]);
    
    if nargin < 4
        popts = {'LineWidth',1.5,'Color',color_blue};
    end
    if nargin < 5
        fopts = {'LineWidth',1,'EdgeColor',color_red,'FaceAlpha',.7};
    end

    x = x(:); y = y(:); yd = yd(:);
    
    assert( (numel(x) == numel(y)) && (numel(x) == numel(yd)), 'Input size mismatch.' );
    assert( all(yd >= 0), 'Deviations should be positive.' );
    
    fh = fill( vertcat(x,flipud(x)), vertcat(y+yd,flipud(y-yd)), color_red, fopts{:} ); hold on;
    ph = plot( x, y, popts{:} ); hold off;

end

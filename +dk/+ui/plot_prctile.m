function [ph,fh] = plot_prctile( x, y, lo, hi, popts, fopts )
% [ph,fh] = plot_prctile( x, y, lo, hi, popts, fopts )
%
% Percentile plot.
% Vector x are the abcissa locations.
% Matrix y should be n x numel(x).
% lo and hi should be integers between 0 and 100.
% 
% This will plot the median of y across rows in blue, on top of an area in red 
% bounded at the top by the "hi" percentile of y across rows, and at the bottom
% by the "lo" percentile of y across rows.
%
% Required: x, y, lo, hi
% Optional: popts, fopts (cell)
%
% Example:
%   x  = linspace( 0, 2*pi, 100 ); 
%   y  = bsxfun( @plus, sin(x), randn(42,100) ); 
%   dk.ui.plot_prctile(x,y,23,66);
%
% Contact: jhadida [at] fmrib.ox.ac.uk


    color_blue = lab2rgb([60 -5 -30]);
    color_red  = lab2rgb([60 45  20]);
    
    if nargin < 5
        popts = {'LineWidth',1.5,'Color',color_blue};
    end
    if nargin < 6
        fopts = {'LineWidth',1,'EdgeColor',color_red,'FaceAlpha',.7};
    end
    
    assert( numel(x) == size(y,2), 'Input size mismatch.' );
    assert( isscalar(lo) && isscalar(hi), 'Lower/higher percentiles should integers between 0 and 100.' );
    
    n = size(y,1);
    x = dk.to_row(x);
    y_md = median(y,1);
    
    if n >= 3
        y_lo = prctile( y, lo, 1 );
        y_hi = prctile( y, hi, 1 );
        fh = fill( horzcat(x,fliplr(x)), horzcat(y_hi,fliplr(y_lo)), color_red, fopts{:} ); hold on;
    end
    ph = plot( x, y_md, popts{:} ); hold off;

end

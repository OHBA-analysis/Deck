function [ph,fh] = plot_std( x, y, yd, popts, fopts )
% [ph,fh] = plot_std( x, y, yd, popts, fopts )
%
% Mean-deviation plot.
% Plot the curve (x,y) on top of a background area spanning (y-yd,y+yd).
%
% Required: x, y, yd (same size vectors)
% Optional: popts, fopts (forwarded to plot and fill, respectively)
%
% Options can be:
%   cell of key/value options
%   1x3 vec (interpreted as color)
%   struct (option names as fields)
%
% yd can also be nx2 or 2xn, to specify the lower/upper bounds of the area.
%
% Example:
%   x  = linspace( 0, 2*pi, 100 ); 
%   y  = sin(x); 
%   yd = .05 + abs(y)/10; 
%   dk.ui.plot_std(x,y,yd);
%
% JH

    if nargin < 4, popts=[]; end
    if nargin < 5, fopts=[]; end

    color_blue = lab2rgb([60 -5 -30]);
    color_red  = lab2rgb([60 45  20]);
    
    % default options (plot and fill)
    popts = set_options( popts, 'Color', 'LineWidth', 1.5, 'Color', color_blue );
    fopts = set_options( fopts, 'EdgeColor', 'LineWidth', 1, 'EdgeColor', color_red, 'FaceAlpha', 0.6 );
    
    % dimensions and formatting
    n = numel(x);
    assert( numel(y)==n, 'y size mismatch.' );
    x = x(:); 
    y = y(:);
    
    % prepare plot
    if numel(yd) == 2*n
        
        % case with upper and lower bounds specified manually
        assert( ismatrix(yd) && any(size(yd)==2), 'yd should be 2xn or nx2.' );
        if size(yd,1)==2, yd = yd'; end % make it nx2
        
    else
        
        % case with std specified 
        yd = yd(:);
        assert( numel(yd)==n, 'yd size mismatch.' );
        assert( all(yd >= 0), 'Deviations should be positive.' );
        yd = [y-yd,y+yd];
    end
    
    % plot it
    fcol  = fopts.EdgeColor;
    fopts = dk.struct.to_cell(fopts);
    popts = dk.struct.to_cell(popts);
    
    fh = fill( [x; flipud(x)], [yd(:,1); flipud(yd(:,2))], fcol, fopts{:} ); hold on;
    ph = plot( x, y, popts{:} ); hold off;

end

function out = set_options( in, cname, varargin )
%
% empty   : defaults are set
% 1x3 vec : interpreted as color
% struct  : converted to a cell
% K/V cell: ok
%

    % convert defaults to structure
    def = struct(varargin{:});
    
    if isempty(in)
        out = def; % set defaults
    elseif isvector(in) 
        assert( numel(in)==3, 'Expected 1x3 color vector.' );
        def.(cname) = in; % interpret as color vector
        out = def;
    else 
        out = in;
    end
    
    if iscell(out)
        out = struct(out{:});
    end
    assert( isstruct(out), 'Bad options type.' );
    
end

function h = surface( x, y, z, varargin )
%
% Combine all the useful stuff that's usually done when drawing surfaces.

    % parse inputs
    opt = dk.obj.kwArgs(varargin{:});
    
    % validate named inputs
    dk.assert( ismatrix(z), 'Third input z should be a matrix.' );
    if numel(x) ~= numel(z) || numel(y) ~= numel(z)
        [x,y] = meshgrid( x(:), y(:) );
    end
    dk.assert( all(size(x)==size(z)) && all(size(y)==size(z)), 'Unexpected size for x and y.' );
    
    % extract other inputs
    in_title  = opt.pop( 'title', '' );
    in_xlabel = opt.pop( 'xlabel', 'x' );
    in_ylabel = opt.pop( 'ylabel', 'y' );
    in_zlabel = opt.pop( 'zlabel', 'z' );
    in_clabel = opt.pop( 'clabel', '' );
    in_clim   = opt.pop( 'clim', 'auto' );
    in_cmap   = opt.pop( 'cmap', 'jet' );
    in_light  = opt.pop( 'light', '' );
    in_color  = opt.pop( 'color', z );
    in_subpos = opt.pop( 'subplot', {} );
    
    % surface options
    in_edge_color = opt.pop( 'EdgeColor', 'none' );
    in_face_color = opt.pop( 'FaceColor', 'interp' );
    
    % subplot option
    if ~isempty(in_subpos), subplot(in_subpos{:}); end
    
    
    % draw the surface
    other = opt.to_cell();
    h = surf( x, y, z, in_color, 'EdgeColor', in_edge_color, 'FaceColor', in_face_color, other{:} ); 
    if ~isempty(in_title), title(in_title); end
    
    % labels
    if ~isempty(in_xlabel), xlabel(in_xlabel); end
    if ~isempty(in_ylabel), ylabel(in_ylabel); end
    if ~isempty(in_zlabel), zlabel(in_zlabel); end
    
    % colormap
    colormap(gca,in_cmap);
    
    % colorbar
    cb = colorbar; caxis(in_clim); 
    if ~isempty(in_clabel), cb.Label.String = in_clabel; end
    
    % lights
    if ~isempty(in_light)
        camlight;
        lighting(gca,in_light);
    end
    
    % axes
    axis vis3d tight; grid on; box off;
    
end

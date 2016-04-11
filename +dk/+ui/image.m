function [h,color_scale] = image( img, varargin )

    % parse inputs
    opt = dk.obj.kwArgs( varargin );
    
    color_scale    = opt.get('color_scale',    [] );
    adapt_scale    = opt.get('adapt_scale',    isempty(color_scale) );
    
    title_str      = opt.get('title',          '' );
    label_x        = opt.get('xlabel',         '' );
    label_y        = opt.get('ylabel',         '' );
    label_c        = opt.get('clabel',         '' );
    remove_ticks   = opt.get('remove_ticks',   isempty(label_x) && isempty(label_y) );
    
    scale_func     = opt.get('scale_func',     @(x) dk.math.round(max(abs(x(:))),1) );
    cmap_name      = opt.get('cmap',          'bgr' );
    subpos         = opt.get('subplot',       {} );
    
    cmap_unsigned  = dk.ui.cmap.(cmap_name)(128,false);
    cmap_signed    = dk.ui.cmap.(cmap_name)(256,true);
    
    % subplot if asked
    if ~isempty(subpos)
        subplot(subpos{:});
    end
    
    % plot image
    if iscell(img)
        x = img{1}; y = img{2}; img = img{3};
        h = imagesc( x, y, img );
        set(gca,'YDir','normal')
    else
        h = imagesc( img ); 
    end
    
    % remove ticks
    if remove_ticks
        set(gca,'xtick',[],'ytick',[]);
    else
        xlabel(label_x);
        ylabel(label_y);
    end
    
    % set color-scale
    if isempty(color_scale)
    if all( img(:) < -eps )
        color_scale   = [-1 0];
        cmap_unsigned = flipud(cmap_unsigned); % reverse colormap
    elseif any( img(:) < -eps )
        color_scale = [-1 1];
    else
        color_scale = [0 1];
    end
    end
    
    % set colormap
    if abs(sum(color_scale)) / sum(abs(color_scale)) < 1e-3
        colormap( gca, cmap_signed );
    else
        colormap( gca, cmap_unsigned );
    end
    
    % adapt color-scale
    if adapt_scale
        color_scale = scale_func(img) * color_scale;
    end
    
    % remaining options
    cb = colorbar(gca); caxis( color_scale ); title(title_str);
    if ~isempty(label_c), cb.Label.String = label_c; end;
    
end

function [h,crange] = image( img, varargin )
%
% [h,crange] = dk.ui.image( img, varargin )
%
% TODO: document this function
%
% JH
    
    % parse inputs
    opt = dk.obj.kwArgs( varargin{:} );
    
    crange     = opt.get('crange',     [] );
    ctype      = opt.get('ctype',      'auto' );
    
    title_str  = opt.get('title',      '' );
    label_x    = opt.get('xlabel',     '' );
    label_y    = opt.get('ylabel',     '' );
    label_c    = opt.get('clabel',     '' );
    rm_ticks   = opt.get('rmticks',    isempty(label_x) && isempty(label_y) );
    rm_bar     = opt.get('rmbar',      false );
    
    cmap_raw   = opt.get('cmap',       'bgr' );
    subpos     = opt.get('subplot',    {} );
    
    maxwidth   = opt.get('maxwidth',   50000 );
    maxheight  = opt.get('maxheight',  50000 );
    maxsize    = [ maxheight, maxwidth ];
    
    if ischar(cmap_raw)
        cmap_unsigned = eval(sprintf('dk.cmap.%s(128,false)', cmap_raw));
        cmap_signed   = eval(sprintf('dk.cmap.%s(256,true)',  cmap_raw));
    else
        cmap_unsigned = [];
        cmap_signed   = [];
    end
    
    % subplot if asked
    if ~isempty(subpos)
        subplot(subpos{:});
    end
    
    % plot image
    if isstruct(img)
        img = {img.x, img.y, img.z};
    end
    if iscell(img)
        
        % x and y axes are given
        [x,y,img] = dk.math.imresample( img{1}, img{2}, img{3}, 'cubic' );
        
        % resize image if needed
        img = check_size(img,maxsize);
        
        % if image was resized, adapt x and y
        [nr,nc] = size(img);
        ny = numel(y); if nr ~= ny, y = interp1( linspace(0,1,ny), y, linspace(0,1,nr) ); end
        nx = numel(x); if nc ~= nx, x = interp1( linspace(0,1,nx), x, linspace(0,1,nc) ); end
        
        % draw image
        h = imagesc(x,y,img); set(gca,'YDir','normal');
        
        % round values for display
        %x = dk.math.round( x(get(gca,'xtick')), 1 );
        %y = dk.math.round( y(get(gca,'ytick')), 1 );
        
        %set( gca, 'xticklabel', arrayfun(@num2str,x,'UniformOutput',false) );
        %set( gca, 'yticklabel', arrayfun(@num2str,y,'UniformOutput',false) );
        
    else
        img = check_size( img, maxsize );
        h = imagesc(img); 
    end
    
    % remove ticks
    if rm_ticks
        set(gca,'xtick',[],'ytick',[]);
    else
        xlabel(label_x);
        ylabel(label_y);
    end
    
    % color range
    [crange,ctype] = dk.cmap.range( img, ctype, crange );
    
    % set color-scale
    switch lower(ctype)
        case {'neg','revsym'}
            cmap = flipud(cmap_unsigned);
        case 'bisym'
            cmap = cmap_signed;
        case 'bool'
            cmap = gray(64);
        otherwise
            cmap = cmap_unsigned;
    end
    
    % override colormap if specified manually
    if ischar(cmap_raw)
        colormap( gca, cmap );
    else
        colormap( gca, cmap_raw );
    end
    caxis( crange ); 
    
    % remaining options
    cb = colorbar(gca); 
    if ~isempty(label_c)
        cb.Label.String = label_c; 
    end
    if rm_bar || islogical(img)
        cb.Visible = 'off'; 
    end
    title(title_str);
    
end

function img = check_size(img,maxsize)

    imgsize = size(img);
    maxsize = min( imgsize, maxsize );
    
    if ~all( imgsize == maxsize )
        warning( 'Input image is too large and will be resized for display.' );
        img = imresize( img, maxsize, 'bicubic' );
    end
    
end

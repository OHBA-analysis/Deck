function resize( f, height, width )
% 
% Resize the window of figure "fig" to a size given in pixels.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin == 2
        width  = height(2);
        height = height(1);
    end
    
    [~,hw,sn] = dk.ui.fig.position(f);
    si = dk.ui.screen.info(sn);
    
    if isempty(height)
        if width > 1
            height = hw(1);
        else
            height = hw(1)/si.size(1);
        end
    end
    if isempty(width)
        if height > 1
            width = hw(2);
        else
            width = hw(2)/si.size(2);
        end
    end
    
    hw = [height,width];
    if all( hw > 1 )
        wh = fliplr(hw);
    else
        wh = fliplr(hw .* si.size);
    end

    u = get(f,'units'); set(f,'units','pixels');
    set( f, 'position', [ si.centre-wh/2, wh ] );
    set(f,'units',u);

end

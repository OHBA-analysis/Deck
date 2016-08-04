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
    sc = dk.ui.screen.centre(sn);
    
    if isempty(height)
        height = hw(1);
    end
    if isempty(width)
        width = hw(2);
    end

    wh = [width,height];
    u = get(f,'units'); set(f,'units','pixels');
    set( f, 'position', [ sc-wh/2, wh ] );
    set(f,'units',u);

end

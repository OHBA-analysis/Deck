function sc = movetoscreen( f, num )

    [~,hw] = dk.ui.fig.position(f);
    sc = dk.ui.screen.centre(num);
    wh = fliplr(hw);
    
    u = get(f,'units'); set(f,'units','pixels');
    set( f, 'position', [ sc-wh/2, wh ] );
    set(f,'units',u);

end
function sc = movetoscreen( f, num )

    [~,hw] = dk.fig.position(f);
    sc = dk.screen.centre(num);
    wh = fliplr(hw);
    
    u = get(f,'units'); set(f,'units','pixels');
    set( f, 'position', [ sc-wh/2, wh ] );
    set(f,'units',u);

end
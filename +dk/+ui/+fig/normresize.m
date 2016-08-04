function normresize( f, nheight, nwidth )
%
% Normalised resizing.
%

    if nargin == 2
        nwidth  = nheight(2);
        nheight = nheight(1);
    end
    
    [~,hw,sn] = dk.ui.fig.position(f);
    si = dk.ui.screen.info(sn);
    
    if isempty(nheight)
        nheight = hw(1)/si.size(1);
    end
    if isempty(nwidth)
        nwidth = hw(2)/si.size(2);
    end
    
    hw = [nheight,nwidth];
    assert( all(hw >= 0 & hw <= 1), 'Bad normalised size.' );
    wh = fliplr(hw .* si.size);
    
    u = get(f,'units'); set(f,'units','pixels');
    set( f, 'position', [ si.centre-wh/2, wh ] );
    set(f,'units',u);

end
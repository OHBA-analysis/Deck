function [cp,hw,sn] = position(f)
%
% cp : center pixel
% hw : height x width
% sn : screen number
%   

    u = get( f, 'units' ); set( f, 'units', 'pixels' );
    p = get( f, 'position' );
    
    % compute coordinates of center pixel
    cp = p(1:2) + p(3:4)/2;
    
    % height and width
    hw = [p(4) p(3)];
    
    % find out in which screen the figure is in
    s  = get( 0, 'MonitorPositions' );
    n  = size(s,1);
    d  = inf(1,n);
    sn = 0;
    
    for i = 1:n
        x = s(i,:);
        d(i) = norm( cp - (x(1:2) + x(3:4)/2) );
        if (cp(1) >= x(1)) && (cp(1) <= x(1)+x(3)) && (cp(2) >= x(2)) && (cp(2) <= x(2)+x(4))
            sn = i; break;
        end
    end
    if sn == 0
        [~,sn] = min(d);
    end
    
    % restore figure units
    set( f, 'units', u );
    
end
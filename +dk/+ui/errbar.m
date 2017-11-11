function h = errbar( x, y, L, t, varargin )
%
% h = dk.ui.errbar( x, y, Ylength, Xwidth, varargin )
%
% Add error bars to the current 2d axes, centered at specified coord (x,y), and with specified length and tick-width.
% If x, y and Ylength are vectors, then multiple bars are plotted.
% Xwidth should be a scalar and is replicated for each bar.
%
% Additional inputs are forwarded to plot.
%
% JH
    
    n = numel(x);
    assert( numel(y)==n, 'x and y size mismatch.' );
    assert( numel(L)==n, 'x and Ylength size mismatch.' );
    assert( isscalar(t), 'Xwidth should be scalar.' );

    % make all vectors rows
    x = dk.torow(x);
    y = dk.torow(y);
    L = dk.torow(L);
    
    % make bars with ticks
    %
    %   1--3--2  ^
    %      |     |
    %      |     | L
    %      |     |
    %   6--4--5  v
    %   <----->
    %      t
    %
    x = [ x-t; x+t; x; x; x+t; x-t ];
    y = [ y+L; y+L; y+L; y-L; y-L; y-L ];
    h = gobjects(1,n);
    
    % draw bars
    hold on;
    for i = 1:n
        h(i) = plot( x(:,i), y(:,i), varargin{:} );
    end
    hold off;
    
end
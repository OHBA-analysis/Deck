function f = new( name, figsize, screen, varargin )

    f = figure( 'name', name, varargin{:} );
    if nargin > 2 && ~isempty(screen)
        dk.ui.fig.movetoscreen(f,screen);
    end
    if nargin > 1 && ~isempty(figsize)
        if all(figsize > 1)
            dk.ui.fig.resize( f, figsize );
        else
            dk.ui.fig.normresize( f, figsize );
        end
    end

end
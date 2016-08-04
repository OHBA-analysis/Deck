function f = new( name, figsize, screen, varargin )
%
% f = new( name, figsize, screen, varargin )
%
%     name : name of the new figure
%  figsize : size of the figure in pixels or normalised units
%   screen : screen in which the figure should be moved to
% varargin : additional arguments forwarded to Figure
%
%        f : figure handle
%
% JH

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
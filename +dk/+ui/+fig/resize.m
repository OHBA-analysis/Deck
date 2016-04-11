function resize( fig, height, width )
% 
% Resize the window of figure "fig" to a size given in pixels.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    unit = fig.Units;
    pos  = fig.Position;
    set( fig, 'units', 'pixels', 'position', [1, 1, width, height] );
    fig.Units = unit;

end

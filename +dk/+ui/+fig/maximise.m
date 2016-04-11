function maximise( fig )
% 
% Maximise the window of figure "fig".
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    unit = fig.Units;
    set( fig, 'Units', 'normalized', 'outerposition', [0 0 1 1] );
    fig.Units = unit;

end

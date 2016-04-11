function tile( grid_size, varargin )
% 
% ui.fig.tile( grid_size, varargin )
%
% Move and resize a group of figures given in input according to a specified grid size [nrows, ncols].
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    assert( nargin > 1, 'Not enough inputs.' );

    % check the number of inputs
    if nargin > 2
        figures = varargin;
    else
        figures = varargin{1};
    end
    
    if ~iscell(figures)
        figures = arrayfun( @(x) x, figures, 'UniformOutput', false );
    end

    % dimensions of the grid
    nrows  = grid_size(1);
    ncols  = grid_size(2);
    ncells = nrows * ncols;
    nfigs  = numel(figures);
    
    assert( nrows > 0 && ncols > 0, 'Bad grid size.' );
    assert( nfigs <= ncells, 'Too many figures to tile.' );
    
    % left-bottom positions for all figures
    [left,bottom] = meshgrid( linspace(0,1,ncols+1), linspace(0,1,nrows+1) );
    left   = left(1:end-1,1:end-1);
    bottom = bottom(1:end-1,1:end-1);
    width  = 1/ncols;
    height = 1/nrows;

    % apply positions
    for i = 1:nfigs
        unit = figures{i}.Units;
        set( figures{i}, 'units', 'normalized', 'outerposition', [left(i) bottom(i) width height] );
        figures{i}.Units = unit;
    end
    
end

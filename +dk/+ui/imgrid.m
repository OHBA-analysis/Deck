function fig = imgrid( slices, names, samerng, varargin )
%
% fig = dk.ui.imgrid( slices, names, samerange=false, varargin )
%
% Opens a new figure and draw each slice of input 3D matrix in a separate subplot.
% The size of the subplot grid is computed using dk.util.gridfit.
% Additional inputs are forwarded to dk.ui.image.
%
% INPUTS
%     slices  Either a 3D matrix or a cell array of matrices.
%             In the second case, the matrices need not be the same size, and each cell 
%             will be shown in a different subplot.
%
%      names  Cell-string with title associated with each subplot.
%             Default title is 'Slice %d'.
%
%    samerng  Display all matrices in the same color-range.
%             Default is false.
%
%   varargin  Additional inputs are forwarded to dk.ui.image.
%
% OUTPUT
%   fig is the figure handle.
%
% See also: dk.ui.image, dk.util.gridfit
%
% JH

    % convert slices to cell
    if isnumeric(slices)
        assert( ndims(slices) <= 3, 'Numeric input should be 3D.' );
        slices = num2cell( slices, [1 2] );
    end

    assert( iscell(slices), 'Input slices should be a cell.' );
    assert( all(cellfun( @(x) ~isvector(x), slices )), 'Cell elements should be matrices.' );
    
    % compute grid size
    n = numel(slices);
    [h,l] = dk.util.gridfit(n);
    
    % default names
    if nargin < 2 || isempty(names)
        names = dk.arrayfun( @(k) sprintf('Slice %d',k), 1:n, false );
    end
    
    % value range
    if nargin < 3 || isempty(samerng)
        samerng = false; 
    end
    if samerng
        r = dk.cellfun( @slice_range, slices, false );
        r = vertcat(r{:});
        r = [min(r(:,1)), max(r(:,2))];
    else
        r = [];
    end
    
    % draw figure
    fig = figure;
    for i = 1:n
        dk.ui.image( slices{i}, 'subplot', {h,l,i}, 'title', names{i}, 'crange', r, ...
            'rmbar', samerng && mod(i,l), varargin{:} );
    end
    
    % save user data
    fig.UserData.slices = slices;
    fig.UserData.names  = names;
    fig.UserData.range  = r;
    fig.UserData.grid   = [h,l];

end

function r = slice_range(s)

    s = dk.util.filtnum(s);
    r = [min(s), max(s)];
    
    if diff(r) < 1e-6
        r = mean(r) + [-1,1]/2;
    end

end
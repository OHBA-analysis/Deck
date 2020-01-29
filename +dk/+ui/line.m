function h = line( coord, color, varargin )
%
% h = dk.ui.line( coord, color, varargin )
%
% Create a line-plot allowing different vertices to have different colors.
%
%   coord   Either Nx2 (2D) or Nx3 (3D)
%   color   Either vector (using colormap) or RGB matrix
%
% Additional options are forwarded to patch.
% 
% See also: patch
%
% JH

    n = size(coord,1);
    coord(end+1,:)=nan;
    color(end+1,:)=nan;
    
    h = patch( 'Faces', 1:n+1, 'Vertices', coord, 'FaceVertexCData', color, ...
        'FaceColor', 'none', 'EdgeColor', 'interp', varargin{:} );

end
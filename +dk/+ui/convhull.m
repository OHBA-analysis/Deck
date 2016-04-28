function [h,D,H] = convhull( X, varargin )
%
% Source: http://stackoverflow.com/questions/5492806/plotting-a-surface-from-a-set-of-interior-3d-scatter-points-in-matlab
%
% This method is appropriate if the set of points in X (which should be nx3) represents a VOLUME SCATTER.
% If the set of points represent a surface, which you want to triangulate, you should use dk.ui.triangulation instead.
%
% An alternative to this method is dk.ui.alphashape.
% See also delaunayTriangulation, convexhull and trisurf in Matlab.
%
% JH

    assert( size(X,2)==3, 'Input should be nx3' );
    
    D = delaunayTriangulation(X);
    H = convexHull(D);
    h = trisurf( H, D.Points(:,1), D.Points(:,2), D.Points(:,3), varargin{:} );

end

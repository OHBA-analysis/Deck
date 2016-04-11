function [h,D,H] = convhull( X, varargin )
%
% from http://stackoverflow.com/questions/5492806/plotting-a-surface-from-a-set-of-interior-3d-scatter-points-in-matlab

    assert( size(X,2)==3, 'Input should be nx3' );
    
    D = delaunayTriangulation(X);
    H = convexHull(D);
    h = trisurf( H, D.Points(:,1), D.Points(:,2), D.Points(:,3), varargin{:} );

end

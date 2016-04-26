function [h,D] = triangulation( X, varargin )
%
% Source: http://uk.mathworks.com/matlabcentral/fileexchange/5105-making-surface-plots-from-scatter-data
%
% This method is appropriate if the set of points in X (which should be nx3) represents a SURFACE in space.
% If the set of points are scattered within a volume, from which you want to extract a surface, you should
% use either dk.ui.convhull or dk.ui.alphashape instead.
%
% See also delaunayTriangulation and trisurf in Matlab.
%
% JH

    assert( size(X,2)==3, 'Input should be nx3.' );
    
    D = delaunayTriangulation(X);
    h = trisurf( D, D.Points(:,1), D.Points(:,2), D.Points(:,3), varargin{:} );
    
end

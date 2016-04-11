function [h,D] = triangulation( X, varargin )
%
% from http://uk.mathworks.com/matlabcentral/fileexchange/5105-making-surface-plots-from-scatter-data

    assert( size(X,2)==3, 'Input should be nx3.' );
    
    D = delaunayTriangulation(X);
    h = trisurf( D, D.Points(:,1), D.Points(:,2), D.Points(:,3), varargin{:} );
    
end

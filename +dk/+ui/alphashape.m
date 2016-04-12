function [h,A] = alphashape( X, varargin )

    assert( size(X,2)==3, 'Input should be nx3' );
    
    A = alphaShape(X(:,1), X(:,2), X(:,3));
    h = A.plot( varargin{:} );

end

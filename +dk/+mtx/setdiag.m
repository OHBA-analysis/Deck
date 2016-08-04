function M = setdiag( M, val )

    assert( ismatrix(M), 'Input should be a matrix.' );
    
    n = size(M,1);
    M( 1:(n+1):(n*n) ) = val;

end
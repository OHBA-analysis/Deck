function S = col2sym( C, strict )
%
% This is the inverse function of dk.matrix.sym2col.

    assert( ismatrix(C), 'Expected a matrix in input.' );
    if nargin < 2, strict = false; end

    m = size(C,1);
    s = size(C,2);
    
    if strict
        n = (1+sqrt(1+8*m))/2;
    else
        n = (sqrt(1+8*m)-1)/2;
    end
    assert( abs(n - floor(n)) < 1e-6, 'Bad number of rows in input.' );
    
    S = zeros(n,n,s);
    I = dk.matrix.symindex(n,strict);
    if strict, I = I + eye(n); end
    
    for i = 1:s
        M = C(:,i);
        M = M(I);
        if strict, M = M - diag(diag(M)); end
        S(:,:,i) = M;
    end
    
end

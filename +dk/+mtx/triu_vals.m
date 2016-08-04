function v = triu_vals( A, k )
% Extract values of A in upper-triangular matrix

    if nargin < 2, k = 1; end

    n = size(A,1);
    T = triu( true(n), k );
    v = A(T);

end

function v = tril_vals( A, k )
% Extract values of A in lower-triangular matrix

    if nargin < 2, k = 1; end

    n = size(A,1);
    T = tril( true(n), -k );
    v = A(T);

end

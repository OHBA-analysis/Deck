function S = symindex( n, strict )
%
% S = ant.mtx.symindex( n, strict=false )
%
% nxn symmetric matrix like
%
%  1  2  3  4  5
%  2  6  7  8  9
%  3  7 10 11 12
%  4  8 11 13 14
%  5  9 12 14 15
    
    if nargin < 2, strict = false; end

    if strict
        M = tril( true(n), -1 );
        S = zeros(n);
        S(M) = 1:( n*(n-1)/2 );
        S = S + S'; % WARNING: you can't use these indices directly, Matlab will complain about diagonal 0s
    else
        M = tril( true(n), 0 );
        S = zeros(n);
        S(M) = 1:( n*(n+1)/2 );
        S = S + S' - diag(diag(S));
    end
    
end

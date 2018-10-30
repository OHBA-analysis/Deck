function x = dirichlet( a, n )
%
%  x = ant.math.dirichlet( a, n )
%
% Sample from a Dirichlet distribution with parameters a (vector).
% The number of elements in a determines the dimensionality.
% n is the number of samples.
%
% See: https://en.wikipedia.org/wiki/Dirichlet_distribution#Gamma_distribution
%
% JH

    a = a(:)';
    d = length(a);
    x = gamrnd( repmat(a,n,1), 1, n, d );
    x = bsxfun( @rdivide, x, sum(x,2) );

end

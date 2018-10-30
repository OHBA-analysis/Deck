function D = pairwise_differences( A, B )
% D = pairwise_differences( A, B )
%
% Matrix of pairwise differences between elements of A and B (both vectors).
% Output is antisymmetric.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 2, B = A; end

    A = A(:);
    B = B(:)';
    D = bsxfun( @minus, A, B );

end

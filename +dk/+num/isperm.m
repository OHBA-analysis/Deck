function yes = isperm(p,len)
%
% yes = dk.num.isperm(p)
% yes = dk.num.isperm(p,n)
%
% Checks whether input vector p is a permutation of 1:n.
% By default, n = numel(p).
%
% JH

    if nargin < 2, len = numel(p); end
    counts = accumarray( p(:), 1, [len,1] );
    yes = all(counts == 1);
end

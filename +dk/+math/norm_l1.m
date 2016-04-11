function n = norm_l1( X, dim )
% n = norm_l1( X, dim )
%
% Compute L1 norms along dimension dim.
%
% Input:
%	X numeric array.
%   dim (default: 1) the dimension that should be reduced.
%
% Constraints:
%	X is numeric, dim is a scalar.
%
% Output:
%	n is an array of same size as X, except that size(n,dim) == 1.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

	if nargin < 2, dim=1; end
	n = sum( abs(X), dim );

end

function C = sym2col( S, strict )
%
% C = ant.mtx.sym2col( S, strict=false )
%
% Converts input symmetric matrix S to a column representation containing the lower-triangular data.
% The order of elements in the output column corresponds to the vertical concatenation of:
%   - first column elements
%   - second column elements under diagonal
%   - third column elements under diagonal
%   - etc.
%
% The second input 'strict' is a boolean flag that specifies whether or not the diagonal elements 
% should be excluded. If strict is false, then the diagonal is included. If strict is true it is not.
% By default, strict is set to false (diagonal included).
%
% S can also be a volume, in which case each slice is treated as an independent matrix and the 
% output columns are concatenated horizontally into a matrix. 
%
% That is, if size(S,1)==size(S,2)==n and size(S,3)==s, then the output C will be n(n+1)/2-by-s
% if strict is false, and n(n-1)/2-by-s if strict is true.

    assert( size(S,1) == size(S,2), 'S should be square.' );
    assert( ndims(S) <= 3, 'S should be a matrix or a volume.' );
    if nargin < 2, strict=false; end

    n = size(S,1);
    s = size(S,3);
    
    if strict
        M = tril(true(n),-1);
        m = n*(n-1)/2;
    else
        M = tril(true(n));
        m = n*(n+1)/2;
    end
    
    C = reshape( S(repmat(M,[1 1 s])), m, s );

end

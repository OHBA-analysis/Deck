function [mat,rev] = squash( mat, dim )
%
% mat = dk.mtx.squash( mat, dim )
%
% Whatever the dimensions of input mat, reshape it as a 2D array where the first dimension
% corresponds to the second input.
%
% * If dim is unspecified, then the first non-singleton dimension is selected.
% * If dim is scalar, then the size of the first dimension in output is the same as size(mat,dim).
% * If dim is an array, then the first output dimension corresponds to the input dimensions
%   concatenated in the order specified.
%
% The second output allows to reverse the trasnformation using dk.mtx.unsquash.
%
% Example:
%
%   x = rand( 1,4,5,1,7,1,3 );
%   compare = @(a,b) all(a(:) == b(:));
%
%   [y1,r1] = dk.mtx.squash(x); compare(x,dk.mtx.unsquash(y1,r1))
%   [y2,r2] = dk.mtx.squash(x,3); compare(x,dk.mtx.unsquash(y2,r2))
%   [y3,r3] = dk.mtx.squash(x,[5,2]); compare(x,dk.mtx.unsquash(y3,r3))
%
% See also: dk.mtx.unsquash
%
% JH

    nd = ndims(mat);

    if nargin < 2, dim = dk.util.nsdim(mat); end
    assert( isnumeric(dim), 'Second input should be numeric.' );
    assert( all( dim>0 & dim<=ndims(mat) ), 'Bad dimension(s).' );
    
    % information for forward transformation
    insize = size(mat);
    other = setdiff(1:nd,dim);
    perm = [ dim, other ];
    nr = prod(insize(dim));
    nc = prod(insize(other));
    
    % save information for reverse transformation
    rev.nd      = nd;
    rev.insize  = size(mat);
    rev.outsize = [nr,nc];
    rev.tmpsize = insize(perm);
    rev.perm    = perm;
    rev.dim     = dim;
    
    % do transformation
    mat = reshape( permute(mat,perm), [nr,nc] );
    
end
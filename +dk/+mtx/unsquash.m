function mat = unsquash( mat, rev )
%
% mat = dk.mtx.unsquash( mat, rev )
%
% Reverse transformation of dk.mtx.squash.
%
% See also: dk.mtx.squash
%
% JH

    assert( all(size(mat) == rev.outsize), 'Bad input.' );
    
    rperm(rev.perm) = 1:rev.nd;
    mat = permute( reshape(mat,rev.tmpsize), rperm );

end
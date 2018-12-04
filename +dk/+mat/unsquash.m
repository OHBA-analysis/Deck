function mat = unsquash( mat, rev )
%
% mat = dk.mat.unsquash( mat, rev )
%
% Reverse transformation of dk.mat.squash.
%
% See also: dk.mat.squash
%
% JH

    assert( all(size(mat) == rev.outsize), 'Bad input.' );
    
    rperm(rev.perm) = 1:rev.nd;
    mat = permute( reshape(mat,rev.tmpsize), rperm );

end

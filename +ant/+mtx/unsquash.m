function mat = unsquash( mat, rev )
%
% mat = ant.mtx.unsquash( mat, rev )
%
% Reverse transformation of ant.mtx.squash.
%
% See also: ant.mtx.squash
%
% JH

    assert( all(size(mat) == rev.outsize), 'Bad input.' );
    
    rperm(rev.perm) = 1:rev.nd;
    mat = permute( reshape(mat,rev.tmpsize), rperm );

end

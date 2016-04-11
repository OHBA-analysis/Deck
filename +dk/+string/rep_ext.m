function s = rep_ext( s, e, n )
%
% Replace extension in string.
% See dk.string.rem_ext and dk.string.set_ext for more details.
% By default, only the part after the last dot is replaced (ie, n=1).
% If the extension to replace contains several dots, set n to a higher value.
%
% For instance, replacing the extension of foo.bar.nii.gz to foo.bar.mat:
% dk.string.rep_ext( '/path/to/foo.bar.nii.gz', 'mat', 2 )

    if nargin < 3, n = 1; end
    s = dk.string.set_ext( dk.string.rem_ext(s,n), e );

end

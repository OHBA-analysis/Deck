function n = nsdim(x) 
%
% n = dk.util.nsdim(x) 
%
% First non-singleton dimension of multidimensional input x.
%
% JH

    n = find(size(x) > 1,1,'first');

end
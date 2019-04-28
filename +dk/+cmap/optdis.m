function c = optdis( dmat, h )
%
% c = optdis( dmat, h=1e-4 )
%
% Optimised colormap based on dissimilarity matrix.
%
% See also: dk.cmap.optsim
%
% JH

    if nargin < 2, h=1e-4; end
    c = dk.cmap.optsim(1./(h + dmat));

end
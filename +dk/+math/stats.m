function s = stats( X, dim )
%
% s = dk.math.stats( X, dim=1 )
%
% Compute basic stats (mean, std, skewness) along a given dimension.
%
% JH

    if nargin < 2, dim = 1; end

    s = struct( ...
        'mean', squeeze(nanmean(X,dim)), ...
        'sdev', squeeze(nanstd(X,[],dim)), ...
        'skew', dk.math.nanreplace(squeeze(skewness(X,[],dim)),0) ...
    );

end

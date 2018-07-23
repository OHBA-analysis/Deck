function s = stats( X, dim, red )
%
% s = dk.msr.stats( X, dim=1, red=forward )
%
% Compute basic stats (mean, std, skewness) along a given dimension.
% red can be used eg to squeeze the results if needed (red=@squeeze).
%
% JH

    if nargin < 2, dim = 1; end
    if nargin < 3, red = @dk.forward; end

    s = struct( ...
        'mean', red(nanmean(X,dim)), ...
        'sdev', red(nanstd(X,[],dim)), ...
        'skew', dk.math.nanreplace(red(skewness(X,[],dim)),0), ...
        'kurt', dk.math.nanreplace(red(kurtosis(X,[],dim)),0)  ...
    );

end

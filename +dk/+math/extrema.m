function [m,M] = extrema( X, dim )

    if nargin < 2, dim = 1; end
    
    m = min(X,[],dim);
    M = max(X,[],dim);

end

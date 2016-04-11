function [mu,sigma] = stats( X, dim )

    if nargin < 2, dim = 1; end

    mu = mean(X,dim);
    sigma = std(X,[],dim);

end

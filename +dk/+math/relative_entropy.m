function [KL,Px,Py] = relative_entropy( x, y, nbins )
%
% Estimate relative entropy (aka KL divergence) between sequences x and y.
% See joint_entropy and entropy for more details about what's happening here.
%
% JH

    if nargin < 3, nbins = 100; end

    % Turn inputs into columns
    assert( numel(x) == numel(y) ); % check they have the same number of elements
    n = numel(x);
    x = x(:);
    y = y(:);
    
    % Set minimum value to 0
    l = min(min(x),min(y));
    x = x-l;
    y = y-l;
    
    % Get bin indices given maximum value
    u = max(max(x),max(y));
    x = 1+floor( nbins*x/u );
    y = 1+floor( nbins*y/u );
    m = nbins+1;
    
    % Get marginal entropies
    Px = accumarray( x, 1, [1,m] )/n;
    Py = accumarray( y, 1, [1,m] )/n;

    % Compute KL divergence
    KL = -dot( Px, log2(Py+eps)-log2(Px+eps) );
    
end
function [G,u] = grouplabels(L,n,t)
%
% [G,u] = dk.grouplabels(L)
% [G,u] = dk.grouplabels(L,n)
% [G,u] = dk.grouplabels(L,n,t)
%
% For each unique label in L, find indices of elements equal to this label.
% Output G is a 1xn cell:
%   - if n is not specified, then n=max(L) by default;
%   - otherwise, if n < max(L), then G only contains the first n groups.
% Output u is a 1xn vector with the corresponding labels.
%
% If t is specified, then:
%   - L should be sorted, and 
%   - t is a 1xn vector, such that t(i) is the index of the first element
%     in L equal to the i^th label.
%
% LABELS SHOULD BE POSITIVE INTEGERS
%
% Complexity is m log(m), where m=length(L).
% In theory, could be improved to linear complexity using integer sort.
% This version is already ~10-20x faster than using Matlab's splitapply.
%
% Example: group elements by rounded value
%
%   x = rand(1,1000);
%   [u,~,L] = unique(round(x,2));
%   G = dk.grouplabels(L,101);
%
% JH

    L = L(:); % make a col
    if nargin < 2, n = max(L); end
    
    % compute t
    if nargin < 3
        
        % count each label
        c = accumarray( L, 1, [n,1] ); % this will fail if L is not proper

        % sort labels
        [~,s] = sort(L,'ascend');

        % define strides in sorted version
        t = 1 + cumsum([0; c]);
        
    else
        
        nL = numel(L);
        assert( isvector(t) && numel(t)==n, 'Bad input t.' );
        assert( all(dk.num.between( t, 1, nL )), 'Bad indices t.' );
        s = 1:nL;
        t(end+1) = nL+1;
        
    end
    
    % define groups
    s = s(:)';
    t = t(:)';
    G = cell(1,n);
    for i = 1:n
        G{i} = s( t(i):(t(i+1)-1) );
    end 
    
    u = L(s(t(1:n)))';
    u(diff(t) == 0) = nan;

end

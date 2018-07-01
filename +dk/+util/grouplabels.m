function G = grouplabels(L,n)
%
% G = dk.util.grouplabels(L)
% G = dk.util.grouplabels(L,n)
%
% For each unique label in L, find indices of elements equal to this label.
% Output G is a 1xn cell:
%   - if n is not specified, then n=max(L) by default;
%   - otherwise, if n < max(L), then G only contains the first n groups.
%
% LABELS SHOULD BE POSITIVE INTEGERS
%
% Complexity is m log(m), where m=length(L).
% In theory, could be improved to linear complexity using integer sort.
% This version is already ~10-20x faster than using splitapply.
%
% Example: group elements by rounded value
%
%   x = rand(1,1000);
%   [u,~,L] = unique(round(x,2));
%   G = dk.util.grouplabels(L,101);
%
% JH

    L = L(:)'; % make a row
    if nargin < 2, n = max(L); end
    
    % count each label
    c = accumarray( L(:), 1 ); % this will fail if L is not proper
    c = c(:)';
    
    % sort labels
    [~,s] = sort(L,'ascend');
    
    % define strides in sorted version
    t = 1 + cumsum([0,c]);
    
    % define groups
    G = cell(1,n);
    for i = 1:n
        G{i} = s(t(i):(t(i+1)-1));
    end

end
function n = msdeq(a,b)
%
% n = dk.num.msdeq(a,b)
%
% Number of equal most significant digits.
%
% JH

    n = floor(log10(max(a,b))) - floor(log10(abs( a-b )));
    
end
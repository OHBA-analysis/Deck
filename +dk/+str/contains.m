function y = contains(h,q)
%
% ans = dk.str.contains(h,q)
%
% Equivalent to ~isempty(strfind(h,q)).
% Replaces latest Matlab function in earlier version.
% 
% JH

    y = ~isempty(strfind(h,q)); %#ok

end
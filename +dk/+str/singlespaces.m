function str = singlespaces( str )
%
% Replace all forms of spaces (multiple spaces, tabs, etc) by a single space, then trim the result.

    str = strtrim(regexprep( str, '(\s+)', ' ' ));

end
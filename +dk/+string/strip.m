function s = strip( s, chars )
%
% Remove specified leading and trailing characters.
%
%  INPUTS
%   s        the string to process
%   chars    the list of characters to remove, defaults to ''
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 2, chars = ''; end

    s = strtrim(s);
    
    if ~isempty(chars)
        s = regexp( s, sprintf('^[%s]*(.*?)[%s]*$',chars,chars), 'tokens' );
        s = s{1};
    end

end

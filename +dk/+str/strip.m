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

    chars = [chars '\s'];
    s = regexp( s, sprintf('^[%s]*(.*?)[%s]*$',chars,chars), 'tokens', 'once' );
    s = s{1};

end

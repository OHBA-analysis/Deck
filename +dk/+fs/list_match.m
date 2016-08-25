function names = list_match( dirname, expr, filter )
%
% names = list_match( dirname, expr, filter=@(x)true )
%
% List names (files or folders) in directory dirname matching an input regexp.
% Folders . and .. are excluded from all search. If empty, dirname defaults to pwd.
%
% JH

    if isempty(dirname), dirname=pwd; end
    if nargin < 3, filter = @(x) true; end
    
    string = @(x) ischar(x) && isrow(x);
    assert( string(dirname) && string(expr) && isa(filter,'function_handle'), ...
        'Unexpected input type(s).' );

    names = dir( dirname ); 
    names = {names.name};
    valid = @(x) ~ismember(x,{'.','..'}) && ~isempty(regexp( x, expr, 'once' )) && filter(fullfile(dirname,x));
    names = names(cellfun( valid, names ));

end

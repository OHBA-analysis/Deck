function files = list_match( dirname, expr, filter )
%
% List files in directory dirname matching an input regexp.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 3, filter = @(x) true; end

    list  = dir( dirname ); 
    nl    = length(list);
    files = {};
    
    for i = 1:nl
        name = regexp( list(i).name, expr, 'match' );
        if ~isempty(name) && filter(fullfile(dirname,name{1}))
            files{end+1} = name{1};
        end
    end

end

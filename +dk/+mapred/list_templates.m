function L = list_templates()

    L = dir(fullfile( dk.mapred.path, 'templates/*.m' ));
    
    if nargout == 0
        L = dk.arrayfun( @(x) dk.str.rem_ext(x.name,1), L, false );
        dk.println('Found %d template(s):',numel(L));
        cellfun( @(x) fprintf('\t%s\n',x), L );
    end

end
function init( fileName, tplName, className )

    if nargin < 3, className = fileName; end
    
    tplfolder = fullfile( dk.mapred.path, 'template' );
    
    % Parse filename
    [folder,file,ext] = fileparts(fileName);
    
    assert( isempty(exp) || strcmp(ext,'.m'), 'Filename extension should be .m' );
    assert( isempty(strfind(className,' ')) && isempty(strfind(className,pathsep)), 'Invalid class name.' );
    assert( dk.fs.is_file(fullfile( tplfolder, [tplName '.m'] )), 'Unknown template.' );
    
    % Create folder if needed
    if ~dk.fs.is_dir(folder)
        dk.assert( mkdir(folder), 'Could not create folder "%s".', folder );
    end
    
    % Load tempalte
    dk.assert( copyfile( fullfile(tplfolder,[tplName '.m']), fullfile(folder,[file '.m']) ), 'Could not copy template file.' );
    dk.assert( copyfile( fullfile(tplfolder,[tplName '.json']), fullfile(folder,[file '.json']) ), 'Could not copy template file.' );

end
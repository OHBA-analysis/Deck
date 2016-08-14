function init( className, tplName, tplOpt, jsonOpt )
%
% dk.mapred.init( className, tplName, jsonOpt, tplOpt )
%
% className : name of the class as it would be called from console (eg 'foo.bar.Baz')
% tplName   : template name (eg 'default')
% jsonOpt   : structure to be merged with the json config
% tplOpt    : structure with additional substitutions for the template
%
% JH

    tplfolder = fullfile( dk.mapred.path, 'templates' );
    if nargin < 2 || isempty(tplName), tplName = 'default'; end
    if nargin < 3 || isempty(tplOpt), tplOpt = struct(); end
    
    assert( isempty(strfind(className,' ')) && isempty(strfind(className,pathsep)), 'Invalid class name.' );
    assert( dk.fs.is_file(fullfile( tplfolder, [tplName '.m'] )), 'Unknown template.' );
    
    % create folder if needed
    fileName = dk.mapred.name2relpath( className );
    [folder,file] = fileparts(fileName);
    if ~isempty(folder) && ~dk.fs.is_dir(folder)
        dk.assert( mkdir(folder), 'Could not create folder "%s".', folder );
        dk.println( 'Created folder "%s".', folder );
    end
    
    % load templates
    tplm = dk.str.Template(fullfile( tplfolder, [tplName '.m'] ),true);
    tplj = dk.json.load(fullfile( tplfolder, [tplName '.mapred.json'] ));
    
    % format templates
    tplOpt.Class = file;
    tplOpt.Name = className;
    tplOpt.ID = dk.time.datestr('longstamp');
    tplm = tplm.substitute( tplOpt );
    
    tplj.id = tplOpt.ID;
    tplj.exec.class = tplOpt.Name;
    if nargin > 3
        tplj = dk.struct.merge( tplj, jsonOpt );
    end
    
    % save formatted templates
    dk.fs.puts( fullfile([fileName '.m']), tplm, true );
    dk.json.save( fullfile([fileName '.mapred.json']), tplj );

end

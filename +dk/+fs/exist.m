function y = exist( name, kind )

    if nargin < 2, kind='any'; end
    
    e = exist(name);
    switch lower(kind)
        
        case 'any'
            y = (e > 0) || ~isempty(which(name)) || ~isempty(dir(name));
        
        case 'file'
            y = ~isempty(dir(name)) && ~isdir(name);
            
        case {'symlink','link'}
            y = dk.fs.is_symlink(name);
            
        case {'folder','dir'}
            y = (e == 7);
            
        case {'variable','var'}
            y = (e == 1);
            
        case 'builtin'
            y = (e == 5);
            
        case {'function','fun'}
            y = ismember( e, [2 3 5 6] ) || ( (e ~= 8) && ~isempty(which(name)) );
            
        case {'mfile','mscript'}
            [~,~,y] = fileparts(which(name));
            y = strcmpi(y,'.m');
            
        case {'mexfile','mex'}
            [~,~,y] = fileparts(which(name));
            y = ~isempty(strfind(y,'.mex'));
            
        case 'class'
            y = (e == 8);
            
    end

end
function [ok,reason] = is_safename( name )

    ok     = false;
    reason = ['Name "' name '" exists as a '];
    
    if dk.fs.is_file(name), reason=[reason 'file.']; return; end
    if dk.fs.is_dir(name),  reason=[reason 'directory.']; return; end
    
    ok     = true;
    reason = '';
    
end

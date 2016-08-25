function [count,safe] = puts( name, txt, overwrite )
%
% Create a file with name "name" with the contents of the string "txt".
% The optional input "overwrite" grants the right to overwrite an exisiting file with name "name".
% Otherwise, a safe name is automatically created by appending a number at the end of "name".
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 3, overwrite = false; end

    % Handle overwrite
    if ~overwrite
        [safe,ow] = dk.fs.safename(name,true);
        if ow > 0
            warning('dk.fs.puts: File "%s" already exists, renaming to "%s".',name,safe);
        end
    else
        safe = name;
    end
    
    % Write to file
    f = fopen(safe,'w'); count = fwrite(f,txt); fclose(f);
    
end

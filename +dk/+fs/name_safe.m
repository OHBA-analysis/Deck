function [safe,count] = name_safe( name, quiet )
% 
% Append the input name with increasing numbers as long as the corresponding file already exists.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 2, quiet = false; end

    safe  = name;
    count = 0;

    while ~dk.fs.is_safename( safe )
        safe  = [name,'_',num2str(count)];
        count = count + 1;
    end
    
    if ~quiet && count > 0
        warning('[dk.fs.name_safe] Filename "%s" was changed to "%s" to prevent overwrite.',name,safe);
    end
    
end

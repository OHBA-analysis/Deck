function n = name_tmp()
% 
% Temporary file/folder name.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    [~,n] = fileparts(tempname());
end

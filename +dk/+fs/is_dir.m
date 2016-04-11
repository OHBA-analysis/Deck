function yes = is_dir( name )
%
% Check whether the input name exists as a directory in the file-system.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    yes = exist( name, 'dir' ) == 7;
end

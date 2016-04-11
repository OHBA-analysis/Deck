function yes = is_file( name )
%
% Check whether the input name exists as a file in the file-system.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    yes = exist( name, 'file' ) == 2;
end

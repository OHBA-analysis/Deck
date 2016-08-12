function install( bindir )

    % default to $HOME/local/bin
    if nargin < 1
        bindir = fullfile(dk.env.home,'local/bin');
        warning( 'No target directory selected, defaulting to "%s".', bindir );
    end
    if ~dk.fs.is_dir(bindir)
        dk.assert( mkdir(bindir), 'Could not create directory "%s".', bindir );
    end

    % move Python scripts there and make them executable
    pyfolder = fullfile( dk.mapred.path, 'python' );
    pyfiles  = dir(fullfile( pyfolder, '*.py' ));
    for i = 1:numel(pyfiles)
        f = pyfiles(i).name;
        dk.assert( copyfile(fullfile(pyfolder,f),fullfile(bindir,f)), 'Could not copy file "%s".', f );
        fileattrib( fullfile(bindir,f), '+x' );
    end
    
end
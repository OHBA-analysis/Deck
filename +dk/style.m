function s = style( name )

    % if no argument, list all available styles
    if nargin < 1
        s = dk.fs.list_files(fullfile( dk.package_dir, 'style' ));
        return;
    end

    name = fullfile( dk.string.set_ext( name, 'mat' ) );
    dk.println('[dk] Loading style "%s".',name);
    s = load(fullfile( dk.package_dir, 'style', name ));
    
end

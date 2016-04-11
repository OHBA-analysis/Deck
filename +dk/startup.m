function startup()

    here = dk.package_dir();
    dk.println('[dk] Starting up from folder "%s".',here);
    addpath(fullfile( here, 'gui/layout' ));
    addpath(fullfile( here, 'gui/layoutdoc' ));
    
end
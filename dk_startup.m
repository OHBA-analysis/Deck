function dk_startup()

    here = fileparts(mfilename('fullpath'));
    dk.println('[dk] Starting up from folder "%s".',here);
    addpath(fullfile( here, 'gui/layout' ));
    addpath(fullfile( here, 'gui/layoutdoc' ));
    
end
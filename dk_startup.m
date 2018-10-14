function dk_startup()

    here = fileparts(mfilename('fullpath'));
    dk.println('[Deck] Starting up from folder "%s".',here);
    dk.env.path_flag( 'DECK_ROOT', here );
    
    % add GUI library
    addpath(fullfile( here, 'gui/layout' ));
    addpath(fullfile( here, 'gui/layoutdoc' ));

    % set console encoding
    try
        slCharacterEncoding('UTF-8');
    catch 
        warning('Could not set character encoding; is Simulink installed?');
    end

end
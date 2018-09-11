function dk_startup()

    here = fileparts(mfilename('fullpath'));
    dk.println('[Deck] Starting up from folder "%s".',here);

    % add GUI library
    addpath(fullfile( here, 'gui/layout' ));
    addpath(fullfile( here, 'gui/layoutdoc' ));

    % set console encoding
    slCharacterEncoding('UTF-8');

end
function dk_startup()

    here = fileparts(mfilename('fullpath'));
    dk.println('[Deck] Starting up from folder "%s".',here);
    set_flag(here);
    
    % add GUI library
    addpath(fullfile( here, 'gui/layout' ));
    addpath(fullfile( here, 'gui/layoutdoc' ));

    % set console encoding
    slCharacterEncoding('UTF-8');

end

function set_flag(here)

    flag = getenv('DECK_ROOT');
    if ~isempty(flag) && ~strcmp(flag,here)
        warning( 'Removing existing Deck instance from path at: "%s"', flag );
        dk.env.clearpath(flag);
    end
    setenv('DECK_ROOT',here);
    
end
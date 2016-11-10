function C = compiler( verbose, debug )

    if nargin < 2, debug   =false; end
    if nargin < 1, verbose =false; end

    C = dk.obj.Compiler();
    
    % Matlab version
	mver  = version('-release');
	myear = str2double( mver(1:4) );
    
    % general compiler options
    C.optimize = ~debug;
    C.debug    =  debug;
    C.verbose  = verbose;
    
    % 64-bits sizes (corresp. to -largeArrayDims option)
    C.use_64b_size = true;
    %C.use_cpp0x    = true;
    
    % use our own mexopts.sh
    here = fileparts(mfilename('fullpath'));
    if myear >= 2016
        if ismac()
            C.opt_file = fullfile( here, 'clang++_maci64.xml' );
        else
            C.opt_file = fullfile( here, 'g++_glnxa64.xml' );
        end
    else
        C.opt_file = fullfile( here, 'mexopts.sh' );
    end

end

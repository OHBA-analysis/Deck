function compile()
%
% Compile C++ functions.
%
% JH

    % sort out paths
    here = fileparts(mfilename('fullpath'));
    pmex = fullfile(here, '+mex');
    p.mex = pmex;
    p.inc = fullfile( pmex, 'inc' );
    p.src = fullfile( pmex, 'src' );
    p.bin = fullfile( pmex, 'bin' );

    % remove all existing executables
    jmx_cleanup( p.bin );
    jmx_cleanup( p.mex );

    % build and copy JMX library
    jmx_build();
    jmx = fullfile( p.bin, 'jmx.o' ); 
    copyfile( jmx_path('inc/jmx.o'), jmx );

    % build utilities
    opt = struct();
    opt.outdir = p.bin;
    opt.arma = true;
    opt.mex = false;

    files = lsx( p.inc, 'cpp' );
    dk.mapfun( @(f) jmake( p, f, opt ), files );

    % build Mex files
    opt = struct();
    opt.outdir = p.mex;
    opt.arma = true;
    opt.mex = true;

    files = lsx( p.src, 'cpp' );
    dk.mapfun( @(f) jmake( p, f, opt ), files );
    
end

function files = lsx( folder, ext )
    files = dk.fs.lsext( folder, ext );
    files = dk.mapfun( @(x) fullfile(folder,x), files, false );
end

function jmake( paths, file, opt )
    obj = lsx( paths.bin, 'o' );
    jmx_compile( [{file},obj], opt, 'ipath', paths.inc );
end
function compile(varargin)
%
% Compile C++/Mex functions.
%
% JH

    % sort out paths
    here = fileparts(mfilename('fullpath'));
    pmex = fullfile(here, '+mex');
    p.mex = pmex;
    p.inc = fullfile( pmex, 'inc' );
    p.src = fullfile( pmex, 'src' );
    p.bin = fullfile( pmex, 'bin' );

    if nargin == 0
        rebuild(p);
        compile_inc(p);
        compile_src(p);
    else
        compile_src(p,varargin);
    end
    
end

function rebuild(p)

    % remove all existing executables
    jmx_cleanup( p.bin );
    jmx_cleanup( p.mex );

    % build and copy JMX library to bin/ folder
    % (bin/ folder is scanned in jmake)
    jmx_build();
    jmxbin = fullfile( p.bin, 'jmx.o' ); 
    copyfile( jmx_path('inc/jmx.o'), jmxbin );

end

function files = lsx( folder, ext )
    files = dk.fs.lsext( folder, ext );
    files = dk.mapfun( @(x) fullfile(folder,x), files, false );
end

function compile_inc(p)

    opt = struct();
    opt.outdir = p.bin;
    opt.arma = true;
    opt.mex = false;

    files = lsx( p.inc, 'cpp' );
    dk.mapfun( @(f) jmake( p, f, opt ), files );
end

function compile_src(p,names)

    opt = struct();
    opt.outdir = p.mex;
    opt.arma = true;
    opt.mex = true;

    if nargin > 1
        files = dk.mapfun( @(x) fullfile(p.src, dk.str.xset(x,'cpp')), names, false );
    else 
        files = lsx( p.src, 'cpp' );
    end
    dk.mapfun( @(f) jmake( p, f, opt ), files );
end

function jmake( paths, file, opt )
    obj = lsx( paths.bin, 'o' );
    jmx_compile( [{file},obj], opt, 'ipath', paths.inc );
end
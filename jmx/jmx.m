function cmd = jmx( files, options, varargin )
%
% cmd = jmx( files, options, varargin )
%
% Compile a Mex file using the JMX library.
%
% files:    path to Mex file
%           or a cell starting with path to Mex file, followed by object files
%
% options + additional inputs: see jmx_compile for help
%
% See also: jmx_compile
%
% JH

    if nargin < 2, options=struct(); end

    objfile = jmx_path('inc/jmx.o');
    if exist(objfile,'file') ~= 2
        jmx_build();
    end
    
    if ~iscell(files)
        files = {files};
    end
    assert( iscellstr(files), 'Bad files list.' );
    files{end+1} = objfile;
    
    cmd = jmx_compile( files, options, varargin{:} );

end
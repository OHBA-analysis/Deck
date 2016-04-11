function dbprintln( fmt, varargin )    
if dk.debug.enabled
    dbstack(1);
    fprintf( ['[dk.debug] ' fmt '\n'], varargin{:} );
end
end

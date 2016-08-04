function dbprintln( fmt, varargin )    
if dk.dbg.enabled
    dbstack(1);
    fprintf( ['[dk.dbg] ' fmt '\n'], varargin{:} );
end
end

function debug( fmt, varargin )
if dk.verbosity([],true) >= 4
    dbstack(1);
    dk.println( ['[dk.DEBUG] ' fmt], varargin{:} );
end
end
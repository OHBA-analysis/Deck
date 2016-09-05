function debug( fmt, varargin )
if dk.verb.get(true) >= dk.verb.get('debug')
    dbstack(1);
    dk.println( ['[dk.DEBUG] ' fmt], varargin{:} );
end
end
function info( fmt, varargin )
if dk.verb.get(true) >= dk.verb.get('info')
    %dk.println( ['[dk.INFO] ' fmt], varargin{:} );
    dk.println( fmt, varargin{:} );
end
end

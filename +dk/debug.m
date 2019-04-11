function debug( varargin )
    dk.logger.default().write( 'd', 2, varargin{:} );
end
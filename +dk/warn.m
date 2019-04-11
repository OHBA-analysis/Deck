function warn( varargin )
    dk.logger.default().write( 'w', 2, varargin{:} );
end
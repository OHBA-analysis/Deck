function s = size( varargin )
% 
% Return the size of all screens in pixels.
%
% JH

    s = dk.ui.screen.info(varargin{:});
    s = vertcat( s.size );
    
end

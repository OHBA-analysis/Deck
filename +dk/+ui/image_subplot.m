function [h,color_scale] = image_subplot( position, img, varargin )

    warning('THIS FUNCTION IS NOW DEPRECATED. Please use dk.ui.image instead.');

    % parse inputs
    args   = dk.obj.kwArgs( varargin );
    parent = args.get('parent',[]);

    % add parent and select subplot
    if ~isempty(parent)
        position = horzcat( position, {'parent',parent} );
    end
    
    subplot( position{:} );
    [h,color_scale] = dk.ui.image( img, varargin{:} );
    
end

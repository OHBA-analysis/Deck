function show( cmap, sz )
%
% dk.ui.cmap.show( cmap, sz=[600 100] )
%

    if nargin < 2, sz=[600 100]; end
    
    cmap = flipud(reshape( cmap, [],1,3 ));
    if sz(2) > sz(1)
        cmap = cmap';
    end
    
    imshow(imresize(cmap,sz,'nearest'));

end
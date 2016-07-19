function show( cmap, sz )

    if nargin < 2, sz=[600 100]; end
    imshow(imresize(flipud(reshape( cmap, [],1,3 )),sz,'nearest'));

end
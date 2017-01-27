function [n,folder] = save_slices( slices, folder, pattern )
%
% [n,folder] = dk.ui.save_slices( slices, folder, pattern )
%
% Save a bunch of stacked images individually into a directory.
% By default, a directory is created on the Desktop.
% The pattern can be used to specify image format.
%
% The command returns the number of images saved, and the folder in which they were saved.
%
% JH

    if nargin < 2, folder = fullfile(dk.env.desktop,dk.fs.tempname); end
    if nargin < 3, pattern = 'img_%d.png'; end

    if ~dk.fs.is_dir(folder)
        dk.assert( mkdir(folder), 'Could not create folder "%s".', folder );
    end
    
    slices = dk.ui.vol2slices(slices);
    n = numel(slices);

    dk.println('[dk.util.save_slices] Saving %d images in folder "%s"...',n,folder);
    for i = 1:n
        imwrite( slices{i}, sprintf(fullfile(folder,pattern),i) );
    end
    
end
function vol2gif( filename, volume, delay, imsize )
%
% VOL2GIF( filename, volume, delay )
%
% Create animated GIF from 3D matrix and save as given filename.
% Default delay is 0.1 sec.
% 
% JH

    if nargin < 3, delay = 0.1; end
    
    % make sure it has the correct extension
    filename = dk.string.set_ext(filename,'gif');
    
    % convert to 256 graylevels
    volume  = round(256*mat2gray(volume));
    nslices = size(volume,3);
    
    % first slice overwrites the file if any
    if nargin > 3
        slice = imresize( volume(:,:,1), imsize, 'nearest' );
    else
        slice = volume(:,:,1);
    end
    imwrite( slice, filename, 'gif', 'WriteMode', 'overwrite', 'DelayTime', delay, 'LoopCount', inf );

    % write other slices to file
    for i = 2:nslices
        
        if nargin > 3
            slice = imresize( volume(:,:,i), imsize, 'nearest' );
        else
            slice = volume(:,:,i);
        end
        
        imwrite( slice, filename, 'gif', 'WriteMode', 'append', 'DelayTime', delay );
    end

end

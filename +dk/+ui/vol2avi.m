function vol2avi( filename, volume, fps, imsize )

    if nargin < 3, fps = 30; end
    
    % open movie file
    writer = VideoWriter( dk.string.set_ext(filename,'avi') );
    writer.FrameRate = fps;
    writer.open();
    
    % convert to 256 graylevels
    volume  = mat2gray(volume);
    nslices = size(volume,3);
    
    % write other slices to file
    for i = 1:nslices
        
        if nargin > 3
            slice = imresize( volume(:,:,i), imsize, 'nearest' );
        else
            slice = volume(:,:,i);
        end
        
        writer.writeVideo( slice );
    end

    % close video file
    writer.close();
    
end

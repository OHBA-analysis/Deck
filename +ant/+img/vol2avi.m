function vol2avi( filename, volume, fps, resize )

    if nargin < 3, fps = 30; end
    
    % open movie file
    writer = VideoWriter( dk.str.xset(filename,'avi') );
    writer.FrameRate = fps;
    writer.open();
    
    % convert to 256 graylevels
    % load slices
    if ischar(volume)
        volume = ant.img.load( volume );
    end
    volume  = ant.img.vol2slices( volume ); % make sure it is a cell
    volume  = dk.mapfun( @mat2gray, volume, false );
    nslices = size(volume,3);
    
    % write other slices to file
    for i = 1:nslices
        
        if nargin > 3
            slice = imresize( volume{i}, resize, 'nearest' );
        else
            slice = volume{i};
        end
        
        writer.writeVideo( slice );
    end

    % close video file
    writer.close();
    
end

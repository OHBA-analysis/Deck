function vol2avi( filename, volume, fps, resize )

    if nargin < 3, fps = 30; end
    
    % open movie file
    writer = VideoWriter( dk.str.set_ext(filename,'avi') );
    writer.FrameRate = fps;
    writer.open();
    
    % convert to 256 graylevels
    % load slices
    if ischar(volume)
        volume = dk.ui.load_slices( volume );
    end
    volume  = dk.ui.vol2slices( volume ); % make sure it is a cell
    volume  = dk.cellfun( @mat2gray, volume, false );
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

function axes2image( haxes, fname, varargin )
%
% Take a snapshot of an axes handle (haxes), and save as an image on disk (fname).
% Additional inputs, if any, are redirected to imresize.
%
% JH

    F = getframe(haxes);
    I = frame2im(F);
    
    if nargin > 2
        I = imresize( I, varargin{:} );
    end
    imwrite( I, fname );

end

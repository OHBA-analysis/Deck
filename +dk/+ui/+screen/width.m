function w = width()
% 
% Return the width of the screen in pixels.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    w = dk.ui.screen.size();
    w = w(2);
end

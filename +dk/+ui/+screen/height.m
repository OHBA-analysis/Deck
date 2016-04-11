function h = height()
% 
% Return the height of the screen in pixels.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    h = dk.ui.screen.size();
    h = h(1);
end

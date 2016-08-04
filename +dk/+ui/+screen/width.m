function w = width(varargin)
% 
% Return the width of the screen in pixels.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    w = dk.ui.screen.size(varargin{:});
    w = w(:,2);
    
end

function s = size()
% 
% Return the size of the screen in pixels.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    s = get(0,'screensize');
    s = [ s(4), s(3) ];
end

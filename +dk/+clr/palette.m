function p = palette( c, w )
%
% p = palette( c, w=[0.2,0.2,0.2,0.8] )
% 
% Create palette from input color.
% See: https://www.viget.com/articles/tints-tones-shades
%
% JH
    
    if isscalar(c), c=hsv2rgb([c 1 1]); end
    if ischar(c), c=dk.clr.hex2rgb(c); end
    assert( dk.is.rgb(c), 'Expected RGB color or hue in input.' );
    
    if nargin < 2, w=[0.2,0.2,0.2,0.8]; end
    
    p.darkest = dk.clr.shade(c,w(1));
    p.darker = dk.clr.tone(c,w(2));
    p.normal = c;
    p.lighter = dk.clr.tint(c,w(3));
    p.lightest = dk.clr.tint(c,w(4));
    
    
    if nargout == 0
        figure;
        im = ones(75,100);
        f = fieldnames(p);
        im = dk.mapfun( @(ff) dk.bsx.mul(reshape(p.(ff),[1,1,3]),im), f, false );
        imshow(vertcat(im{:}));
    end

end
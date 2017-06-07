function c = proc( c1, c2, w )
%
% c = dk.clr.proc( c1, c2, w=0.5 )
%
% Used internally by other functions.
% Mix input colors, allowing inputs to be HEX colors.
% If first input is HEX, then output is HEX too.
% Second input can be HEX, but doesn't affect the output.
%
% JH

    if nargin < 3, w=0.5; end
    if ischar(c2), c2 = dk.clr.hex2rgb(c2); end
    
    if ischar(c1)
        c1 = dk.clr.hex2rgb(c1);
        c = dk.clr.mix(c1,c2,w);
        c = dk.clr.rgb2hex(c);
    else
        c = dk.clr.mix(c1,c2,w);
    end
    
end
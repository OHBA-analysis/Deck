function style = export( fig, fname, style )
% 
% Export a figure "fig" to an image named "fname" using the export style (string or struct) "style".
% If the style is specified as a string, then the style is loaded from Matlab and this might throw 
% an error if it doesn't exist. The default style is used if nothing is specified.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 3,    style = 'default'; end
    if ischar(style), style = hgexport('readstyle',style); end

    hgexport( fig, fname, style );
    
end

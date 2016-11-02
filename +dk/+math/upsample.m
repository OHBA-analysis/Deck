function [y, ty]  = upsample( x, tx, fs, method )
%
% [y, ty] = dk.math.upsample( x, tx, fs, method=pchip )
%
% Upsample a time-series using interpolation.
%
% JH
    
    if nargin < 4, method = 'pchip'; end
    
    [x,tx] = dk.util.format_ts(x,tx,'vertical');
    
    % check that fs is greater than current sampling rate
    dt = mean(diff(tx));
    assert( fs > 1/dt, 'Requested sampling rate is lower than current one, use dk.math.downsample instead.' );
    
    % interpolate
    ty = colon( tx(1), 1/fs, tx(end) )';
    y  = interp1( tx, x, ty, method );
    
end
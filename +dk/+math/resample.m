function [y, ty] = resample( x, tx, fs, method )
%
% [y, ty] = dk.math.resample( x, tx, fs=[], method=pchip )
%
% Wrapper for Matlab function, taking care to demean/remean and using high-precision non-extrapolating method by default.
% Note that if input fs is empty, this method resamples the input at equally spaced points.
%
% JH

    if nargin < 4, method = 'pchip'; end
    if nargin < 3, fs = []; end
    
    [x,tx] = dk.util.format_ts(x,tx,'vertical');
    if isreal(x)

        m = mean(x,1);
        if isempty(fs)
            [y,ty] = resample( dk.bsx.sub(x,m), tx, method );
        else
            [y,ty] = resample( dk.bsx.sub(x,m), tx, fs, method );
        end
        y = dk.bsx.add(y,m);
        
    else
        
        % resample magnitude and angle separately for complex signals
        [yabs,ty] = dk.math.resample( abs(x), tx, fs, method );
        yphi = dk.math.resample( unwrap(angle(x),[],1), tx, fs, method );
        y = yabs .* exp( 1i * yphi );
        
    end

end
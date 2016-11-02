function [env,phi,frq] = ansig( x, fs )
%
% [env,phi,frq] = dk.math.ansig( x, fs=1 )
%
% Decomposed analytic signal from input data.
% 
% INPUTS:
%
%     x    Ntimes x Nsignals matrix, sampled arithmetically in time (equally-spaced points).
%    fs    Input sampling frequency, used for estimating instantaneous frequency (default: 1Hz).
% 
% OUTPUTS:
%
%   env    Oscillatory envelopes for each signal.
%   phi    Instantaneous phase for each signal.
%   frq    Instantaneous frequency for each signal 
%          Computed only if required, in cycles/unit unless fs is defined.
%
% JH
    
    if nargin < 2, fs=1; end

    % compute envelope and phase
    sig = hilbert(dk.bsx.sub( x, mean(x,1) ));
    env = abs(sig);
    phi = unwrap( angle(sig), [], 1 );
    
    % estimate frequency only if required
    if nargout >= 3
        n = size(x,1);
        t = (1:n)/fs;
        
        frq = dk.math.deriv_sample( t, phi ) / (2*pi);
    end

end
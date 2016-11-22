function varargout = ansig( x, fs )
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

    sig = hilbert(dk.bsx.sub( x, mean(x,1) ));
    
    switch nargout
        case 1
            varargout = {sig};
        case 2
            % compute envelope and phase
            varargout = { abs(sig), unwrap( angle(sig), [], 1 ) };
        case 3
            % estimate frequency only if required
            n = size(x,1);
            t = (1:n)/fs;
            
            phi = unwrap( angle(sig), [], 1 );
            frq = dk.math.deriv_sample( t, phi ) / (2*pi);
            varargout = { abs(sig), phi, frq };
    end

end
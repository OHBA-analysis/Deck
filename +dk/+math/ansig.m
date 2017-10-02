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
%          NOTE: the envelope is NOT re-meaned.
%   phi    Instantaneous phase for each signal.
%   frq    Instantaneous frequency for each signal 
%          Computed only if required, in cycles/unit unless fs is defined.
%
% If only one output is set, then the complex analytic signal is returned. That is:
%
%   [env,~] = dk.math.ansig(x); % real-valued envelope returned 
%   as = dk.math.ansig(x); % complex-valued analytic signal returned
%
% If no output is collected, a new figure is opened, showing the trajectory of the analytic
% signal in the complex plane.
%
% JH
    
    if nargin < 2, fs=1; end

    sig = hilbert(dk.bsx.sub( x, mean(x,1) ));
    
    switch nargout
        case 0
            figure;
            [x,y] = pol2cart( angle(sig), abs(sig) );
            plot( x, y, 'k-' );
            title('Complex analytic signal');
            axis equal; grid on;
        case 1
            varargout = {sig};
        case 2
            % compute envelope and phase
            varargout = { abs(sig), unwrap( angle(sig), [], 1 ) };
        case 3
            % estimate frequency only if required
            phi = unwrap( angle(sig), [], 1 );
            frq = dk.math.diff( phi, 1/fs ) / (2*pi);
            varargout = { abs(sig), phi, frq };
    end

end
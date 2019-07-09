function varargout = ansig( x, fs )
%
% [env,phi,frq] = ant.ts.ansig( x, fs=1 )
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
%   [env,~] = ant.ts.ansig(x); % real-valued envelope returned 
%   as = ant.ts.ansig(x); % complex-valued analytic signal returned
%
% If no output is collected, a new figure is opened, showing the trajectory of the analytic
% signal in the complex plane.
%
% JH
    
    if nargin < 2, fs=1; end

    [sig,env] = antran(x);
    
    switch nargout
        case 0
            figure;
            [x,y] = pol2cart( angle(sig), env );
            plot( x, y, 'k-' );
            title('Complex analytic signal');
            axis equal; grid on;
            
        case 1
            varargout = {env.*sig};
            
        case 2
            % compute envelope and phase
            varargout = { env, angle(sig) };
            
        case 3
            % estimate frequency only if required
            phi = angle(sig);
            x = cos(phi);
            y = sin(phi);
            frq = x .* ant.ts.diff( y, fs ) - y .* ant.ts.diff( x, fs );
            frq = max( frq, 0 ) / (2*pi);
            varargout = { env, phi, frq };
    end

end

function [sig,env] = antran(x)
    x = dk.bsx.sub( x, mean(x,1) );
    [~,env] = ant.ts.envelope(abs(x));
    sig = hilbert(x./max(eps,env));
end

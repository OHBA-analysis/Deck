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

    if isreal(x)
        [sig,env] = antran(x); % compute analytic transform on real inputs
    else
        sig = x; % otherwise, assume analytic signal is given
        env = abs(sig);
    end
    
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
            frq = ant.priv.phase2freq( phi, fs );
            varargout = { env, phi, frq };
    end

end

% analytic transform with symmetric enveloping
function [sig,env] = antran(x)

    [lo,up] = ant.ts.envelope(x);
    x = x - (lo+up)/2;
    
    env = (up-lo)/2;
    sig = hilbert( x ./ max(eps,env) );
    
end

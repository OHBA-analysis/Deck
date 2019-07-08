function varargout = ansig_downsample( varargin )
%
% [time,mag,phi] = downsample_ssig( time, mag, phi, fs )
% [time,vals] = downsample_ssig( time, vals, fs )
%
% Downsample the magnitude and phase of any time-resolved spectral signal.
% We tested multiple methods for precision and found that (see jh.test.analytic_resample) using
% sliding-averages with hamming window offered the best compromise between accuracy and speed.
%
% JH

    switch nargin
        case 3 % complex input
            time = varargin{1};
            fs   = varargin{3};
            assert( ~isreal(varargin{2}), 'Expected complex time-courses.' );
            
            [outV,outT] = ant.ts.downsample( abs(varargin{2}), time, fs );
            outV = outV .* exp(1i*ant.ts.downsample( unwrap(angle(varargin{2}),[],1), time, fs ));
            
            varargout = {outT,outV};
            
        case 4
            time = varargin{1};
            fs   = varargin{4};
            
            mag = ant.ts.downsample( varargin{2}, time, fs );
            [phi,time] = ant.ts.downsample( varargin{3}, time, fs );
            
            varargout = {time,mag,phi};
    end
    
end

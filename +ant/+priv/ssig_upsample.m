function varargout = ssig_upsample( varargin )
%
% [time,mag,phi] = upsample_ssig( time, mag, phi, fs )
% [time,vals] = upsample_ssig( time, vals, fs )
%
% Upsample the magnitude and phase of any time-resolved spectral signal.
%
% JH

    switch nargin
        case 3 % complex input
            time = varargin{1};
            fs   = varargin{3};
            assert( ~isreal(varargin{2}) );
            
            [outV,outT] = ant.ts.upsample( abs(varargin{2}), time, fs );
            outV = outV .* exp(1i*ant.ts.upsample( unwrap(angle(varargin{2}),[],1), time, fs ));
            
            varargout = {outT,outV};
            
        case 4
            time = varargin{1};
            fs   = varargin{4};
            
            mag = ant.ts.upsample( varargin{2}, time, fs );
            [phi,time] = ant.ts.upsample( varargin{3}, time, fs );
            
            varargout = {time,mag,phi};
    end
    
end

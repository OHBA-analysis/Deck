classdef TFSeries < handle
%
% ant.dsp.TFSeries()
%
% Time-frequency objects store the spectral contents (typically complex-valued) produced
% by time-frequency analysis, for instance:
%   ant.dsp.wavelet
%   ant.dsp.hilebrt
%
% The properties are:
%    time  Vector of timepoints
%    vals  Complex-valued matrix with spectrum for each time-course
%    freq  Either a scalar (wavelet) or a 1x2 band vector (hilbert)
%   pnorm  Normalisation scalar used to compute power density.
% 
%
% Methods available fall into several categories:
%
%   FORMAT: cartesian, polar
%   TRANSFORM: resample, filter, smooth
%   PROPERTIES: psd, amplitude, magnitude, phase, dphase, phase_offset, synchrony
%   CONNECTIVITY: connectivity, edge_connectivity, cwcorr
%
% + sliding and adaptive variants
% + summary method
%
% See comments for more details about how to call these various methods.
%
% JH

    properties
        time;
        vals;
        freq;
        pnorm;
    end
    
    properties (Transient,Dependent)
        nt, ns, dt, fs, cenfrq, isband;
    end
    
    methods
        
        function self = TFSeries(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function clear(self)
            
            self.time = [];
            self.vals = [];
            self.freq = [];
            self.pnorm = 1;
            
        end
        
        function n = get.nt(self), n = numel(self.time); end
        function n = get.ns(self), n = size(self.vals,2); end
        function t = get.dt(self), t = mean(diff(self.time)); end
        function f = get.fs(self), f = 1/self.dt; end
        function f = get.cenfrq(self), f = mean(self.freq); end
        function y = get.isband(self), y = numel(self.freq)==2; end
        
        function t = tframe(self)
            t = [self.time(1),self.time(end)];
        end
        
        function self = assign(self,time,vals,freq,pnorm)
            
            if nargin < 5, pnorm=1; end
            
            [vals,time] = dk.formatmv(vals,time,'vertical');
            assert( ~isreal(vals), 'This class is for complex-valued signals representing time-resolved spectra.' );
            assert( numel(freq)<=2 && all(freq > eps), 'Frequency(-band) should be positive.' );
            assert( isscalar(pnorm) && pnorm > eps, 'Power norm should be positive scalar.' );
            
            self.time = time;
            self.vals = vals;
            self.freq = freq;
            self.pnorm = pnorm;
            
        end
        
        function s = clone(self)
            s = ant.dsp.TFSeries( self.time, self.vals, self.freq, self.pnorm );
        end
        
    end
    
    %------------------
    % I/O
    %
    %   serialise()
    %   unserialise(s)
    %
    %   save(filename)
    %   load(filename)
    %
    % Also implements: savobj, loadobj
    %
    %------------------
    methods
        
        function [p,n] = get_props(self)
            p = {'time','vals','freq','pnorm'};
            n = numel(p);
        end
        
        function x = serialise(self)
            x.version = '0.1';
            [p,n] = self.get_props();
            for i = 1:n
                x.(p{i}) = self.(p{i});
            end
            x.vals = single(x.vals); % reduce size
        end
        
        function self = unserialise(self,x)
            switch x.version
            case '0.1'
                [p,n] = self.get_props();
                for i = 1:n
                    self.(p{i}) = x.(p{i});
                end
            end
            self.vals = double(self.vals); % expand
        end
        
        function self = save(self,filename)
            x = self.serialise();
            dk.savehd( filename, x );
        end
        function x = saveobj(self)
            x = self.serialise();
        end
        
        function self = load(self,filename)
            dk.disp('[ant.dsp.TFSeries] Loading file "%s"...',filename);
            self.unserialise(load(dk.str.xset(filename,'mat')));
        end
        
    end
    methods (Static)
        
        function x = loadobj(in)
            if isstruct(in)
                x = ant.dsp.TFSeries();
                x.unserialise(in);
            else
                warning('Unknown serialised Signal format.');
                x = in;
            end
        end
        
    end
    
    %------------------
    % TRANSFORM
    %
    %   cartesian()
    %   polar()
    %   smooth( polar=true )
    %   resample( fs )
    %   filter( -10 )
    %
    %------------------
    methods
        
        function [x,y,t] = cartesian(self)
        %
        % [x,y,t] = cartesian()
        %
        
            x = real(self.vals);
            y = imag(self.vals);
            t = self.time;
        end
        
        function [m,p,t] = polar(self)
        %
        % [m,p,t] = polar()
        %
        
            m = abs(self.vals);
            p = unwrap(angle(self.vals),[],1);
            t = self.time;
        end
        
        function self = smooth(self,polar,varargin)
        %
        % self = smooth( polar=true, varargin )
        %
        % Use Matlab's smooth function to smooth the spectral time-courses.
        % If polar=true, the function is applied separately to the magnitude and phase.
        % Additional arguments are forwarded to smooth.
        %
        % See also: smooth
        %
        
            if nargin < 2 || isempty(polar), polar=true; end
            
            if polar
                mag = smooth( self.time, abs(self.vals), varargin{:} );
                phi = smooth( self.time, unwrap(angle(self.vals),[],1), varargin{:} );
                self.vals = mag .* exp( 1i*phi );
            else
                self.vals = smooth( self.time, self.vals, varargin{:} );
            end
            
        end
        
        function s = mask(self,tmask,smask)
        %
        % mask( tmask, smask )
        %
        % Return a TFSeries object (or change in-place) with masked time-course and signals.
        %
            
            if nargin < 3, smask=1:self.ns; end
            if nargin < 2 || isempty(tmask), tmask=1:self.nt; end
            
            if nargout == 0
                self.time = self.time(tmask);
                self.vals = self.vals(tmask,smask);
            else
                s = ant.dsp.TFSeries( self.time(tmask), self.vals(tmask,smask), self.freq, self.pnorm );
            end
            
        end
        
        function self = resample(self,fs,tol)
        %
        % resample( fs, tol=0.1 )
        %
        % Use ant.priv.(down|up)sample_ssig to resample the complex time-courses.
        % Tolerance is used to prevent resampling if current sampling frequency is close enough.
        %
        
            if nargin < 3, tol=0.1; end
            if abs(fs - self.fs) <= tol
                dk.info( '[ant.dsp.TFSeries:resample] Already at the required sampling rate.' );
            elseif fs <= self.fs
                [self.time,self.vals] = ant.priv.ssig_downsample( self.time, self.vals, fs );
            else
                [self.vals,self.time] = ant.priv.ssig_upsample( self.vals, self.time, fs );
            end
        end
        
        function self = filter(self,varargin)
        %
        % self = filter( string, options... )
        % self = filter( numeric, options... )
        % self = filter( struct, options... )
        %
        % Filter the magnitude of the spectral time-courses.
        % Arguments are forwarded to ant.dsp.do.filter
        %
            
            mag = ant.TimeSeries( self.time, abs(self.vals) );
            mag = ant.dsp.do.filter(mag,varargin{:});
            phi = angle(self.vals);
            
            self.vals = mag.vals .* exp( 1i*phi );
            
        end
        
    end
    
    
    %------------------
    % ANALYSIS
    %
    %   Format [x,t] = property( idx )
    %       psd
    %       amplitude
    %       magnitude
    %       phase
    %       dphase
    %       phase_offset
    %       synchrony
    %
    %------------------
    methods
        
        function s = rem_before(self,t)
            if nargout == 0
                tmsk = self.time >= t; % >= is consistent with ant.TimeSeries
                self.time = self.time(tmsk);
                self.vals = self.vals(tmsk,:);
                s = self;
            else
                s = self.clone();
                s.rem_before(t);
            end
        end
        
        function [p,t] = psd(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            t = self.time(tidx);
            p = self.vals(tidx,:);
            p = p .* conj(p) / self.pnorm;
        end
        
        function [a,t] = amplitude(self,varargin)
            [a,t] = self.psd(varargin{:});
            a = sqrt(a);
        end
        
        function [m,t] = magnitude(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            m = abs(self.vals(tidx,:));
            t = self.time(tidx);
        end
        
        function [p,t] = phase(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            t = self.time(tidx);
            p = unwrap( angle(self.vals(tidx,:)), [], 1 );
        end
        
        % normalised derivative of the phase (instantaneous frequency estimate)
        function [f,t] = dphase(self,varargin)
            [f,t] = self.phase(varargin{:});
            h = t(2)-t(1);
            f = ant.ts.diff(f,h)/(2*pi);
        end
        
        function [o,t] = phase_offset(self,varargin)
        %
        % At each timepoint, difference with the average phase across TCs.
        %
        
            [o,t] = self.phase(varargin{:});
            
            o = dk.bsx.sub( o, mean(o,2) );
            o = atan2( cos(o), sin(o) );
        end
        
        function [s,t] = synchrony(self,varargin)
            [s,t] = self.phase(varargin{:});
            s = abs(mean( exp( 1i*s ), 2 ));
        end
        
    end
    
    %------------------
    % SLIDING
    %
    %   Format [x,t] = sliding_property( reduce, [len,step,burn] )
    %       sliding_psd
    %       sliding_amplitude
    %       sliding_magnitude
    %       sliding_phase
    %       sliding_synchrony
    %
    %     If reduce=[], it defaults to @(t) mean(t,1).
    %     The function is invoked with the output of self.property( tidx ).
    %
    %
    %   Format [x,t,w] = adaptive_property( reduce, nosc, burn=0, ovr=0.5 )
    %       adaptive_psd
    %       adaptive_amplitude
    %       adaptive_magnitude
    %       adaptive_phase
    %       adaptive_synchrony
    %
    %   See also summary method below.
    %
    %------------------
    methods
        
        function [p,t] = sliding_prop(self,name,rfun,swin)
            if isempty(rfun), rfun=@(x) mean(x,1); end
            assert( isa(rfun,'function_handle'), 'Expected function handle in input.' );
            [p,t] = ant.dsp.slidingfun( @(~,ti,te) rfun(self.(name)(ti:te)), self, swin );
            p = vertcat(p{:}); % Nwin x Nsig
        end
        
        function [p,t] = sliding_psd(self,varargin)
            [p,t] = self.sliding_prop('psd',varargin{:});
        end
        function [a,t] = sliding_amplitude(self,varargin)
            [a,t] = self.sliding_prop('amplitude',varargin{:});
        end
        function [a,t] = sliding_magnitude(self,varargin)
            [a,t] = self.sliding_prop('magnitude',varargin{:});
        end
        function [p,t] = sliding_phase(self,varargin)
            [p,t] = self.sliding_prop('phase',varargin{:});
        end
        function [s,t] = sliding_synchrony(self,varargin)
            [s,t] = self.sliding_prop('synchrony',varargin{:});
        end
        
        % varargin = nosc[cycles], burn[sec], ovr[ratio] (cf adaptive_win)
        function [x,t,w] = adaptive_prop(self,name,rfun,varargin)
            w = adaptive_swin(self.cenfrq,varargin{:});
            [x,t] = self.sliding_prop(name,rfun,w);
        end
        
        function [p,t,w] = adaptive_psd(self,varargin)
            [p,t,w] = self.adaptive_prop('psd',varargin{:});
        end
        function [a,t,w] = adaptive_amplitude(self,varargin)
            [a,t,w] = self.adaptive_prop('amplitude',varargin{:});
        end
        function [m,t,w] = adaptive_magnitude(self,varargin)
            [m,t,w] = self.adaptive_prop('magnitude',varargin{:});
        end
        function [p,t,w] = adaptive_phase(self,varargin)
            [p,t,w] = self.adaptive_prop('phase',varargin{:});
        end
        function [s,t,w] = adaptive_synchrony(self,varargin)
            [s,t,w] = self.adaptive_prop('synchrony',varargin{:});
        end
        
        % plot spectrogram
        function plot(self,varargin)
            
            [p,t] = self.psd();
            f = self.freq;
            
            % line-plot for multiband, image for wavelet analysis
            if self.isband
                plot( t, p );
                xlabel(xlab); ylabel('PSD'); 
                dk.ui.title('PSD in band [%.0f - %.0f] Hz',f(1),f(2));
            else
                plot( t, p );
                xlabel(xlab); ylabel('PSD'); 
                dk.ui.title('PSD at %.0f Hz',f);
            end
            
        end
        
    end
    
end

function swin = adaptive_swin(cenfrq,nosc,burn,ovr)

    if nargin < 3, burn=0; end
    if nargin < 4, ovr=0.5; end
    
    assert( burn >= 0, 'Burn-in should be non-negative.' );
    assert( (ovr >= 0) && (ovr < 1), 'Overlap should be in [0,1).' );
    
    swin = [ nosc/cenfrq, (1-ovr)*nosc/cenfrq, burn ];

end

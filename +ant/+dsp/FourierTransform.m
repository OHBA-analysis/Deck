classdef FourierTransform < ant.priv.SpectralProperties

    properties
        frq; % frequency
        dfc; % discrete Fourier coefficients (complex)
    end

    properties (Transient,Dependent)
        nf, ns, df;

        % short names
        amp, nrg, psd, phi;

        % Long names
        frequency;
        amplitude;
        energy;
        phase;

    end

    %-------------------
    % Instance methods
    %-------------------
    methods

        % Constructor
        function self = FourierTransform(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end

        % Clear
        function clear(self)
            self.frq = [];
            self.dfc = [];
        end

        % Copy
        function copy(self,s)
            self.frq = s.frq;
            self.dfc = s.dfc;
        end

        % Clone
        function s = clone(self)
            s = ant.dsp.FourierTransform();
            s.copy( self );
        end


        % Dependent properties
        function n = get.nf(self), n = numel(self.frq); end % num of frequencies (single-sided)
        function n = get.ns(self), n = size(self.psd,2); end % num of signals
        function f = get.df(self), f = self.frq(2)-self.frq(1); end % frequency step

        function p = get.phi (self), p = unwrap(angle(self.dfc)); end
        function x = get.psd (self), x = self.nrg / self.df; end
        function e = get.nrg (self), e = abs(self.dfc).^2; end
        function a = get.amp (self), a = abs(self.dfc); end

        function p = get.phase     (self), p = self.phi; end
        function e = get.energy    (self), e = self.nrg; end
        function a = get.amplitude (self), a = self.amp; end
        function f = get.frequency (self), f = self.frq; end


        % Assign from time-series
        function assign(self,ts,demean)

            if nargin < 3, demean=true; end

            % make sure ts is sampled arithmetically
            if ~ts.is_arithmetic()
                warning('Input time-series is not uniformly sampled, resampling before transform.');
                ts = ts.make_arithmetic();
            end

            % demeaning
            if demean, ts = ts.demean(); end

            % compute transform
            [self.frq,self.dfc] = ant.ts.fourier( ts.vals, ts.fs );

        end
        
        
        % Inherited from SpectralProperties
        function f = proxy_frq(self)
            f = self.frq;
        end
        
        function p = proxy_nsp(self)
            p = self.energy;
            p = bsxfun( @rdivide, p, sum(p,1) );
        end

    end

    %-------------------
    % Plotting methods
    %-------------------
    methods

        function phase_lines(self,varargin)

            [low,up] = self.global_power_band;
            plot( self.frq', self.phi', varargin{:} );
            xlabel('Frequency (Hz)'); ylabel('Phase'); xlim([low,up]);
            title('Phase Spectrum');
        end

        function psd_lines(self,varargin)

            [low,up] = self.global_power_band;
            plot( self.frq', self.psd', varargin{:} );
            xlabel('Frequency (Hz)'); ylabel('PSD'); xlim([low,up]);
            title('Power Spectral Density');
        end

        function psd_image(self,varargin)

            [low,up] = self.global_power_band;
            imagesc( self.frq', self.nf:-1:1, self.psd', varargin{:} );
            xlabel('Frequency (Hz)'); ylabel('PSD'); xlim([low,up]);
            title('Power Spectral Density'); colorbar;
        end

    end

end

classdef TFDistribution < handle
%
% Spectral aggregate.
%
% See also: ant.dsp.TFSeries
%
% JH

    properties
        sig
    end
    
    properties (Transient,Dependent)
        ns, nf, ismultiband;
    end
    
    methods
        
        function self = TFDistribution(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function clear(self)
            self.sig = {};
        end
        
         % dimensions
        function n = get.nf(self), n = numel(self.sig); end
        
        function y = get.ismultiband(self)
            if self.nf
                y = self.sig{1}.isband;
            else
                y = false;
            end
        end
        
        function n = get.ns(self)
            if self.nf
                n = self.sig{1}.ns;
            else
                n = 0;
            end
        end
        
        % time/frequency info
        function s = signal(self,k)
            s = self.sig{k}; 
        end
        function t = tframe(self) 
            t = dk.mapfun( @(x) x.tframe, self.sig );
        end
        function f = freq(self,centre)
            if nargin < 2, centre=false; end
            if self.ismultiband
                f = dk.mapfun( @(x) x.freq, self.sig, false );
                if centre, f = cellfun( @mean, f ); end
            else
                f = cellfun( @(x) x.freq, self.sig );
            end
        end
        
        % burn-in
        function rem_before(self,t)
            n = self.nf;
            for i = 1:n
                self.sig{i}.rem_before(t);
            end
        end
        
        % assign spectral signals
        function self = assign(self,varargin)
            
            % get input
            input = varargin;
            if numel(input) == 1 && iscell(input{1})
                input = input{1};
            end
            
            % clear contents if empty
            if isempty(input)
                self.clear();
                return
            end
            
            % check inputs
            assert( all(cellfun( @(x) isa(x,'ant.dsp.TFSeries'), input )), ...
                'Input should be a cell of Signal objects.' );
            
            t = dk.mapfun( @(x) x.time(1), input, true );
            n = numel(t);
            assert( all(diff(t)==0), 'Start times should be equal.' );
            
            % assign input
            self.sig = reshape( input, [1 n] );
            
        end
        
        % return logical mask for signals matching input frequency band (1x2 vector)
        function match = band_match(self,b)
            f = self.freq;
            if self.ismultiband
                match = cellfun( @(x) nst.util.band_overlap(x,b), f ) > 0.95;
            else
                match = (f >= b(1)) & (f <= b(2));
            end
        end
        
        % return only signals matching input frequency band (or modify current object)
        function obj = band_select(self,b)
            match = self.band_match(b);
            if nargout > 0
                obj = ant.dsp.TFDistribution(self.sig(match));
            else
                self.sig = self.sig(match);
            end
        end
        
    end
    
    %------------------
    % I/O
    %------------------
    methods
        
        function x = serialise(self)
            x.version = '0.1';
            x.sig = self.sig;
        end
        
        function self = unserialise(self,x)
            switch x.version
            case '0.1'
                self.sig = x.sig;
            end
        end
        
        function self = save(self,filename)
            x = self.serialise();
            dk.savehd( filename, x );
        end
        function x = saveobj(self)
            x = self.serialise();
        end
        
        function self = load(self,filename)
            dk.disp('[ant.dsp.TFDistribution] Loading file "%s"...',filename);
            self.unserialise(load(filename));
        end
        
    end
    methods (Static)
        
        function x = loadobj(in)
            if isstruct(in)
                x = ant.dsp.TFDistribution();
                x.unserialise(in);
            else
                warning('Unknown serialised Aggregate format.');
                x = in;
            end
        end
        
    end
    
    %------------------
    % ANALYSIS
    %------------------
    methods
        
        % estimate resampled timepoints
        function t = resampled_time(self,fs)
            t = self.tframe;
            t = vertcat(t{:});
            t = [max(t(:,1)), min(t(:,2))];
            t = t(1):1/fs:t(2);
        end
        
        % estimate resampled property across frequencies
        % valid names are:
        %
        %   psd
        %   amplitude
        %   magnitude
        %   phase
        %   dphase
        %   phase_offset
        %   synchrony
        %
        function [p,t,f] = resample(self,name,fs,red)
            
            if nargin < 4, red = @(x) x; end
            name = lower(name);
            
            % output timepoints
            t = self.resampled_time(fs);
            f = self.freq;
            
            % iterate on each signal to interpolate the PSD
            n = self.nf;
            p = cell( 1, n );
            for k = 1:n
                [sp,st] = self.sig{k}.(name);
                p{k} = ant.ts.resample( red(sp), st, t );
            end
            
        end
        
        % average magnitude/phase across frequencies
        function [m,p,t] = average(self,fs)
            
            if nargin < 2, fs = self.sig{1}.fs; end
            
            n = self.nf;
            t = self.resampled_time(fs);
            m = 0;
            p = 0;
            
            for k = 1:n
                [a,b,c] = self.sig{k}.polar();
                m = m + ant.ts.resample(a, c, t);
                p = p + ant.ts.resample(b, c, t);
            end
            m = m / n;
            p = p / n;
            
        end
        
        % average resampled property across frequencies
        function [p,t,c] = xfmean(self,varargin) 
            
            [q,t] = self.resample(varargin{:});
            
            % don't concatenate it in 3D (not memory efficient)
            n = numel(q);
            p = q{1}; % time x signal
            c = 1:size(p,2);
            
            for i = 2:n
                p = p + q{i};
            end
            p = p / n;
            
        end
        
        % PSD statistics on an adaptive sliding window
        function stat = psd_stats( self, varargin )
            
            n = self.nf;
            stat = cell(1,n);
            
            for i = 1:n
                [p,~,s] = self.sig{i}.adaptive_psd( [], varargin{:} );
                
                % average PSD across timepoints for each channel
                p = ant.stat.summary( p, 1 );
                p.swin = s;
                p.freq = self.sig{i}.freq;
                stat{i} = p;
            end
            
            % convert to struct-array
            stat = [stat{:}];
            
        end
        
        % Functional connectivity stats
        function [stat,tc] = connectivity_stats( self, method, varargin )
            
            n = self.nf;
            stat = cell(1,n);
            tc = cell(1,n);
            to_matrix = @(x) ant.mat.col2sym(x,true);
            
            for i = 1:n
                [fc,t,s] = self.sig{i}.adaptive_connectivity( method, varargin{:} );
                
                % average connectivity across edges for each window
                x.time = t;
                x.vals = mean(fc,1)';
                tc{i} = x;
                
                % average connectivity across windows for each edge
                fc = ant.stat.summary( fc, 2 );
                fc.swin = s;
                fc.freq = self.sig{i}.freq;
                fc.mean = to_matrix(fc.mean);
                fc.sdev = to_matrix(fc.sdev);
                fc.skew = to_matrix(fc.skew);
                
                stat{i} = fc;
            end
            
            % convert to struct-array
            stat = [stat{:}];
            tc = [tc{:}];
            
        end
        
        % Coherence-weighted connectivity stats
        function [stat,tc] = cwcorr_stats( self, norm, dsl, varargin )
            
            n = self.nf;
            stat = cell(1,n);
            tc = cell(1,n);
            to_matrix = @(x) ant.mat.col2sym(x,true);
            
            for i = 1:n
                [fc,t,s] = self.sig{i}.adaptive_cwcorr( norm, dsl, varargin{:} );
                
                % average connectivity across edges for each window
                x.time = t;
                x.vals = mean(fc,1)';
                tc{i} = x;
                
                % average connectivity across windows for each edge
                fc = ant.stat.summary( fc, 2 );
                fc.swin = s;
                fc.freq = self.sig{i}.freq;
                fc.mean = to_matrix(fc.mean);
                fc.sdev = to_matrix(fc.sdev);
                fc.skew = to_matrix(fc.skew);
                
                stat{i} = fc;
            end
            
            % convert to struct-array
            stat = [stat{:}];
            tc = [tc{:}];
            
        end
        
    end
    
    %------------------
    % SUMMARY
    %------------------
    methods
        
        function data = summary( self, varargin )
            data = dk.mapfun( @(x) x.summary(varargin{:}), self.sig, false );
            data = [data{:}];
        end
        
        % cross-channel PSD plot
        function [t,f,p] = xcplot(self,name,fs,varargin)
            
            % average PSD across channels for each frequency
            [p,t,f] = self.resample(name, fs, @(x) mean(x,2) );
            p = [p{:}];
            
            % line-plot for multiband, image for wavelet analysis
            if self.ismultiband
                plot( t, p );
                bname = nst.util.band2name(f);
                xlabel('Time (sec)'); ylabel(name); legend(bname{:}); 
            else
                arg = dk.obj.kwArgs({'xlabel','Time (sec)','ylabel','Frequency (Hz)','clabel',name}).merge(varargin{:});
                ant.img.show( {t,f,p}, arg );
            end
            
        end
        function xcdist(self,varargin)
            switch nargin
                case 2
                    x = varargin{1}; % struct
                    p = x.p;
                    f = x.f;
                case 3
                    name = varargin{1};
                    if ischar(name)
                        fs = varargin{2};
                        [p,~,f] = self.resample(name, fs, @(x) mean(x,2) );
                        p = [p{:}];
                    else
                        p = name;
                        f = varargin{2};
                    end
                otherwise
                    error('Bad number of inputs.');
            end
            if self.ismultiband
                bname = nst.util.band2name(f);
                nst.ui.util.violin(p,bname); 
                %xlabel('Frequency Band (Hz)'); 
            else
                nst.ui.util.violin(p,f); 
                xlabel('Frequency (Hz)'); axis tight;
            end
        end
        
        % cross-frequency PSD plot
        function [t,c,p] = xfplot(self,name,fs,varargin)
            
            % if used with positive properties, set 'positive', true
            [p,t,c] = self.xfmean(name,fs);
            arg = dk.obj.kwArgs({'xlabel','Time (sec)','ylabel','Signal #','clabel',name}).merge(varargin{:});
            ant.img.show( {t,c,p}, arg );
            
        end
        function xfdist(self,varargin)
            switch nargin
                case 2
                    x = varargin{1}; % struct
                    p = x.p;
                    c = x.c;
                case 3
                    name = varargin{1};
                    if ischar(name)
                        fs = varargin{2};
                        [p,~,c] = self.xfmean(name,fs);
                    else
                        p = name;
                        c = varargin{2};
                    end
                otherwise
                    error('Bad number of inputs.');
            end
            nst.ui.util.violin(p,c); 
            xlabel('Channel'); axis tight;
        end
        
    end
    
end


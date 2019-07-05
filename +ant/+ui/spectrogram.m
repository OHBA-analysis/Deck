function [p,t,f] = spectrogram( ts, freq, fs, sigma, varargin )
%
% [psd,time,freq] = ant.ui.spectrogram( ts, freq, fs=100, sigma=[], varargin )
% 
% Compute the CWT of input signals at frequencies freq, then resample the average (cross-chanel) 
% spectral signals at each frequency to a common sampling rate, and optionally smooth the result
% with a Gaussian filter for improved display.
% 
% Additional inputs are forwarded to ant.img.show
% NOTE: this function does NOT open a new window by default (ie it draws in gcf)
%
% JH

    if nargin < 4 || isempty(sigma), sigma=0; end
    if nargin < 3 || isempty(fs), fs=100; end

    PROP = 'psd';
    METH = 'resample';
    
    % computation method
    switch METH
        
        case 'manual'
            tf = ant.dsp.wavelet( ts, freq, fs, true );
            p = dk.mapfun( @(x) mean(x.(PROP),2), tf.sig, false );
            f = tf.freq;
            t = tf.sig{1}.time;
            
        case 'resample'
            tf = ant.dsp.wavelet( ts, freq );
            [p,t,f] = tf.resample( PROP, fs, @(x) mean(x,2) );
        
    end
    
    % concatenate and smooth PSD
    p = horzcat( p{:} );
    if sigma > 0
        p = imgaussfilt( p, sigma );
    end
    
    % display
    ant.img.show( {t,f,p}, 'xlabel','Time (sec)', 'ylabel','Frequency (Hz)', 'clabel','PSD', varargin{:} );

end

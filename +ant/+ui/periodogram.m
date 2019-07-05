function den = periodogram( ts, method, varargin )
%
% den = ant.ui.periodogram( ts, method, varargin )
%
% Compute Fourier spectral density using specified method, and plot the result.
% The method defaults to 'pwelch' if the input signal has more than 2000 timepoints.
% Additional arguments are forwarded to ant.dsp.Spectrum.plot
%
% See also: ant.dsp.Spectrum
%
% JH

    if nargin < 2 || isempty(method)
        if ts.nt > 2000
            method = 'welch';
        else
            method = 'fourier';
        end
    end

    den = ant.dsp.Spectrum(ts,method);
    arg = [{'parent',gca},varargin];
    den.plot(arg{:});

end

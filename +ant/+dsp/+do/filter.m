function [ts_out,filt] = filter( ts_in, filt, varargin )
%
% [ts_out,filt] = filter( ts_in, filt )
% [ts_out,filt] = filter( ts_in, filt, options... )
%
% Filter input time-courses using FIR filter.
% Main option is:
%
%   processor
%       nst, default: use ant.dsp.do.filter_butter
%       fieldtrip, ft: use ant.dsp.do.ft_*
%
% If filter_butter is used, then the additional options are defined:
%
%   order: the order of the Butterworth filter (default: 15)
%   tol: the safety margin at the border of relative frequencies (default: 1e-2)
% 
% See also: ant.priv.filter_parse, ant.dsp.do.filter_butter, ant.dsp.do.ft_*
%
% JH

    assert( ts_in.is_arithmetic(), 'Input time-series should be arithmetically sampled.' );

    % parse options (if any)
    opt = dk.obj.kwArgs(varargin{:});

    % parse input filter command
    filt = ant.priv.filter_parse(filt);
    
    % don't filter if input is empty
    if isempty(filt)
        ts_out = ts_in; 
        return; 
    end
    
    % select processor
    switch lower(opt.get( 'processor', 'nsl' ))
        case {'fieldtrip','ft'}
        proc = struct(...
            'lp', @ant.dsp.do.ft_lowpass,  ...
            'hp', @ant.dsp.do.ft_highpass, ...
            'bp', @ant.dsp.do.ft_bandpass, ...
            'bs', @ant.dsp.do.ft_bandstop  ...
        );
        case {'nsl','nst','default'}
        proc = struct(...
            'lp', @(t,f,varargin) ant.dsp.do.filter_butter('lp',t,f,varargin{:}), ...
            'hp', @(t,f,varargin) ant.dsp.do.filter_butter('hp',t,f,varargin{:}), ...
            'bp', @(t,f,varargin) ant.dsp.do.filter_butter('bp',t,f,varargin{:}), ...
            'bs', @(t,f,varargin) ant.dsp.do.filter_butter('bs',t,f,varargin{:})  ...
        );
    end
    
    % run filter
    switch lower(filt.type)
        case {'lp','lowpass','low'}
            ts_out = proc.lp( ts_in, filt.freq, opt );
        case {'hp','highpass','high'}
            ts_out = proc.hp( ts_in, filt.freq, opt );
        case {'bp','bandpass','band'}
            ts_out = proc.bp( ts_in, filt.freq, opt );
        case {'bs','bandstop','stop'}
            ts_out = proc.bs( ts_in, filt.freq, opt );
            
        otherwise
            error('Unknown filter type "%s".',filt.type);
    end

end

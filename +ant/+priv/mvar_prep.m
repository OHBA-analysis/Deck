function [ts,m] = mvar_prep( ts, cut, fac )
%
% [ts,m] = mvar_prep( ts, cut=0.99, fac=3 )
%
% Demean and resample to a frequency consistent with power distribution
%   by default: 3*minfreq(cumpow >= 0.99)
%
% JH
    
    if nargin < 3, fac=3; end
    if nargin < 2, cut=0.99; end

    m = ts.mean();
    T = ant.dsp.FourierTransform(ts);
    ts = T.ts.resample( fac*T.power_cut(cut) );
    
end

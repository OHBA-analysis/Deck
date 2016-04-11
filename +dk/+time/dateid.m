function [d,fmt] = dateid( ms_precision )
% 
% Produces date strings chronolexically ordered with up to millisecond precision.
% Default format goes to seconds only, ie 'yy-mmm-dd_HHMMSS'.
% Use the flag "ms_precision" to include milliseconds.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 1, ms_precision = false; end
        
    if ms_precision
        fmt = 'yy-mmm-dd_HHMMSS_FFF';
    else
        fmt = 'yy-mmm-dd_HHMMSS';
    end
    d = datestr(now,fmt);
        
end

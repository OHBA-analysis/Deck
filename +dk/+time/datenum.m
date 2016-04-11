function [d,fmt] = datenum()
% 
% Produces a short 6-characters date string meant to be used with a day-precision.
% The format is 'yymmdd'.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    fmt = 'yymmdd';
    d   = datestr(now,fmt);
        
end

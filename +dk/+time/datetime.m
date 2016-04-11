function [d,fmt] = datetime()
% replacement for versions of Matlab older than 2014b

    fmt = 'dd-mmm-yy HH:MM:SS';
    d   = datestr(now,fmt);
end

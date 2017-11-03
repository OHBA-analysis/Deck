function [d,fmt] = datestr( type )
%
% [d,fmt] = datestr( type=default )
%
% Return string representation of current date.
% Supports a variety of named format, some without time or time-only.
% First output is the string, second output is the format.
%
%        Chronolexical: longstamp, stamp, shortstamp
%   convertible to int: longnum, num, shortnum
%            Time-only: time, longtime
%   convertible to int: timenum, longtimenum
%            Date-only: longdate, date, shortdate, datenum
%                 Full: datetime (default)
%
% Note 1: long formats include milliseconds
%
% JH

    if nargin < 1 || isempty(type), type='default'; end

    switch lower(type)
        
        % chronolexically ordered
        case {'longstamp','timestamp_long'}
            fmt = 'yyyy-mm-dd_HH:MM:SS.FFF';
        case {'stamp','timestamp'}
            fmt = 'yyyy-mm-dd_HH:MM:SS';
        case {'shortstamp','timestamp_short'}
            fmt = 'yy-mm-dd_HH:MM:SS';
            
        % convertible to integers
        case {'longnum','number_long'}
            fmt = 'yyyymmddHHMMSSFFF';
        case {'num','number'}
            fmt = 'yyyymmddHHMMSS';
        case {'shortnum','number_short'}
            fmt = 'yymmddHHMMSS';
            
        % time-only
        case 'time'
            fmt = 'HH:MM:SS';
        case {'longtime','time_long'}
            fmt = 'HH:MM:SS.FFF';
            
        % time-only convertible to integer
        case 'timenum'
            fmt = 'HHMMSS';
        case {'longtimenum','timenum_long'}
            fmt = 'HHMMSSFFF';
            
        % date-only
        case {'longdate','date_long'}
            fmt = 'mmmm dd, yyyy';
        case {'date'}
            fmt = 'dd-mmm-yyyy';
        case {'shortdate','date_short'}
            fmt = 'yy-mm-dd';
        case 'datenum'
            fmt = 'yyyymmdd';
            
        % Matlab's datetime format
        case {'datetime','default'}
            fmt = 'dd-mmm-yyyy HH:MM:SS';
            
        otherwise
            error( 'Unknown type "%s".', type );
            
    end
    
    d = datestr( now, fmt );

end
function [pos,num] = numbers( str, varargin )
%
% [pos,num] = dk.str.numbers( str, Option1, Option2 ... )
%
% Extract numbers from string.
% Options are specified as strings:
%
%   'int'   Integers only (will not parse floating point)
%   'uint'  Unsigned integers only
%   'once'  Stop searching after the first number found
%
% The first output pos is a Nx2 array where N is the number of matches (=1 with option 'once'),
% and where the columns denote respectively the first and last character index of each match.
%
% The second output is an array containing the matches themselves in double type.
%
% Example:
% [pos,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.')
% [pos,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.','int')
% [pos,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.','uint')
% [pos,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.','int','once')
%
% JH

    % all options to lower case
    opt = dk.cellfun( @lower, varargin, false );

    % parse all numbers
    expr = '-?[0-9]+(\.[0-9]+)?([e|E][-0-9]+)?';
    if ismember('once',opt)
        [first,last] = regexp( str, expr, 'once' );
    else
        [first,last] = regexp( str, expr );
    end

    % put together outputs
    pos = [ first(:), last(:) ];
    num = dk.arrayfun( @(k) str2double(str( first(k):last(k) )), 1:numel(first), true );

    % filter depending on options
    %isint = @(x) isequal( x, fix(x) );
    isint = @(x) ceil(x) == floor(x);

    if ismember('uint',opt)

        mask = isint(num) & (num >= 0);
        pos  = pos( mask, : );
        num  = num( mask );

    elseif ismember('int',opt)

        mask = isint(num);
        pos  = pos( mask, : );
        num  = num( mask );

    end

end
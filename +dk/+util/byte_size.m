function [bsize,scale] = byte_size( b, unit_symbol )
% [bsize,scale] = byte_size( b, unit_symbol='B' )
%
% formats an input bytesize as a struct with conversions to kB, MB, GB and TB
% if it is a bitsize, not a bytesize, you can set the unit symbol to 'b' instead

    if nargin < 2, unit_symbol='B'; end

    units = dk.cellfun( @(x) [x unit_symbol], {'','k','M','G','T','P'}, false );
    scale = units{min( numel(units), 1+floor( log(b)/log(1024) ) )};
    
    for i = 1:numel(units)
        u = units{i};
        bsize.(u) = b / 1024^(i-1);
    end
    
    if nargout == 0
        fprintf('%.2f %s\n', bsize.(scale), scale );
    end
    
end

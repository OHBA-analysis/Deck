function [bsize,scale] = var_size( in, in_bytes )
% [bsize,scale] = var_size( in, in_bytes=true )
%
% return the size of the input variable in bytes or bits
% if there is no output, the size is printed out at the best scale

    w = whos('in');
        
    % in bytes by default, otherwise convert to bits
    if nargin < 2, in_bytes=true; end
    if in_bytes
        b = w.bytes; 
        s = 'B';
    else
        b = 8*w.bytes; 
        s = 'b';
    end
    
    if nargout == 0
        dk.util.byte_size( b, s );
    else
        [bsize,scale] = dk.util.byte_size( b, s );
    end

end

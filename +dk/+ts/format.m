function [x,tx] = format( x, tx, type )
%
% [x, tx] = dk.ts.format( x, tx, type='vert' )
% 
% Format time-series data vertically or horizontally.
%
% JH

    if nargin < 3, type='vert'; end

    n = numel(tx);
    assert( isreal(tx), 'Timepoints must be real-valued.' );
    assert( ismatrix(x) && any(size(x)==n), 'Values/timepoints size mismatch.' );
    
    switch lower(type)
        case {'vertical','vert','v','col'}
            tx = tx(:);
            if size(x,2)==n && size(x,1)~=n
                x = transpose(x);
            end
        case {'horizontal','horz','h','row'}
            tx = tx(:)';
            if size(x,1)==n && size(x,2)~=n
                x = transpose(x);
            end
    end
    
end
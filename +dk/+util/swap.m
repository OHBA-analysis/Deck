function x = swap( x, i, j )
%
% x = dk.util.swap( x, i, j )
%
% Swap to elements in x.
% If x is a structure (or struct-array) then i and j should be fieldnames to swap.
%
% JH

    if iscell(x)
        tmp  = x{j};
        x{j} = x{i};
        x{i} = tmp;
    elseif isstruct(x)
        assert( ischar(i) && ischar(j) );
        n = numel(x);
        for k = 1:n
            tmp = x(k).(j);
            x(k).(j) = x(k).(i);
            x(k).(i) = tmp;
        end
    else
        tmp  = x(j);
        x(j) = x(i);
        x(i) = tmp;
    end
    
end
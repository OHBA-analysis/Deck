function c = compare( v1, v2 )
%
% Generic comparison function between two values v1 and v2.
% Performs a recursive comparison on types:
%   cell, struct, numeric, logical
%
% and any other type/class which implements the operator ==.
%
% JH

    FP_THRESHOLD = 1e-10;

    if isstruct(v1)
        
        n = numel(v1);
        f = fieldnames(v1);
        c = isstruct(v2) && (numel(v2) == n);
        i = 1;
        
        while c && (i <= n)
            for j = 1:numel(f)
                c = c && dk.compare( v1(i).(f{j}), v2(i).(f{j}) );
            end
            i = i+1;
        end
        
    elseif iscell(v1)
        
        n = numel(v1);
        c = iscell(v2) && (numel(v2) == n);
        i = 1;
        
        while c && (i <= n)
            c = c && dk.compare( v1{i}, v2{i} );
            i = i+1;
        end
        
    elseif ischar(v1)
        c = ischar(v2) && strcmp(v1,v2);
        
    elseif isnumeric(v1)
        %c = isnumeric(v2) && (numel(v1) == numel(v2)) && all( v1(:) == v2(:) );
        c = isnumeric(v2) && (numel(v1) == numel(v2)) && ( max(abs(v1(:)-v2(:))) < FP_THRESHOLD );
    
    elseif islogical(v1)
        c = islogical(v2) && (numel(v1) == numel(v2)) && ~xor(v1,v2);
        
    else
        try
            c = all(v1 == v2);
        catch
            warning( 'Dont know how to compare values of type "%s".', class(v1) );
            c = false;
        end
    end

end

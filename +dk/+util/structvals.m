function v = structvals( s )
% v = STRUCTVALS( s )
%
% Returns a N x M cell-array where N is the size of the input struct-array and M is the number of fields.
% Cell (i,j) contains the value of i^th field in the j^th structure.
%
% JH

    n = numel(s);
    f = fieldnames(s);
    m = numel(f);
    v = cell( m, n );
    
    for i = 1:n
    for j = 1:m
        v{j,i} = s(i).(f{j});
    end
    end

end

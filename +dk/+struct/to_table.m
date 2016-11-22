function T = to_table( s )
% 
% Convert struct-array to table
%
% JH

    f = fieldnames(s);
    n = numel(f);
    m = numel(s);
    T = cell(1,n);
    
    for i = 1:n
        T{i} = reshape( {s.(f{i})}, m, 1 );
    end
    T = [T,{'VariableNames',f}];
    T = table(T{:});

end
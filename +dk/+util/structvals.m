function v = structvals( s )
% v = STRUCTVALS( s )
%
% Returns a N x M cell-array where N is the size of the input struct-array and M is the number of fields.
% Cell (i,j) contains the value of j^th field in the i^th structure.
%
% JH

    f = fieldnames(s);
    nstruct = numel(s);
    nfields = numel(f);
    v = cell( nstruct, nfields );
    
    for i = 1:nstruct
    for j = 1:nfields
        v{i,j} = s(i).(f{j});
    end
    end

end

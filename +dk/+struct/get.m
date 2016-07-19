function default = get( s, fname, default )
%
% Get a field value from a structure if the field exists.
% If not, return the default value specified.
% If the input is a struct array, the output is a cell of the same size.

    n = numel(s);
    if isfield(s,fname)
        if n > 1
            default = reshape( {s.(fname)}, size(s) ); 
        else
            default = s.(fname); 
        end
    elseif n > 1 
        default = repmat( {default}, size(s) );
    end

end

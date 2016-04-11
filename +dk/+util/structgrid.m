function grid = structgrid( row_field, row_vals, col_field, col_vals )
%
% Example: dk.util.structgrid( 'row.foo', {'a','b','c'}, 'col', [1 2 3 4] )
% Limitation: only one (sub)field can be defined in each dimension for now...
%
% JH

    assert( ischar(row_field) && ischar(col_field), 'Fielnames should be strings.' );

    nrows = numel(row_vals);
    ncols = numel(col_vals);
    
    % process fieldnames
    row_field = dk.util.string2substruct(row_field);
    col_field = dk.util.string2substruct(col_field);
    
    % create empty structure to allocate output
    mock = subsasgn( struct(), row_field, [] );
    mock = subsasgn( mock, col_field, [] );
    
    % create accessors for row/col values
    function f = get_accessor(x)
        if iscell(x)
            f = @(y,k) y{k}; 
        else
            f = @(y,k) y(k); 
        end
    end
    rval = get_accessor( row_vals );
    cval = get_accessor( col_vals );
    
    % allocate output and assign values for each field
    grid = repmat( mock, nrows, ncols );
    for r = 1:nrows
    for c = 1:ncols
        
        grid(r,c) = subsasgn( grid(r,c), row_field, rval(row_vals,r) );
        grid(r,c) = subsasgn( grid(r,c), col_field, cval(col_vals,c) );
        
    end
    end

end

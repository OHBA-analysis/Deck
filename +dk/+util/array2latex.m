function L = array2latex( values, rows, cols )

    if nargin < 3, cols = {}; end
    if nargin < 2, rows = {}; end
    
    % Parse values into a cell
    if isnumeric(values)
        
        V = arrayfun( @make_string, values, 'UniformOutput', false );
        
    elseif iscell(values)
        
        V = cellfun( @make_string, values, 'UniformOutput', false );
        
    elseif istable(values)
        
        rows = values.Properties.RowNames;
        cols = values.Properties.VariableNames;
        L = jh.util.array2latex( table2array(values), rows, cols );
        return;
        
    else
        error('Nope');
    end
    
    % Add columns and rows
    if ~isempty(cols)
        V = vertcat( cols, V );
    end
    if ~isempty(rows)
        if ~isempty(cols)
            rows = vertcat( {''}, rows );
        end
        V = horzcat( rows, V );
    end
    
    % Find the largest field in each column
    width = cellfun(@length,V);
    
    % Allocate output
    [nr,nc] = size(V);
    
    s = [0,cumsum( max(width,[],1)+4 )];
    L = repmat( ' ', [nr,s(end)] );
    
    % Fill columns one by one
    for c = 1:nc
    
        for r = 1:nr
            L( r, s(c)+(1:width(r,c)) ) = V{r,c};
        end
        
        L(:,s(c+1)-2) = '&';
    end
    L(:,end-2:end-1) = repmat('\\',[nr,1]);

end

function s = make_string( v )

    if ischar(v)
        s = v;
    elseif isnumeric(v)
        s = sprintf( '%g', v );
    elseif islogical(v)
        s = {'false','true'};
        s = s{v};
    else
        error( 'Dont know how to convert value to string.' );
    end

end
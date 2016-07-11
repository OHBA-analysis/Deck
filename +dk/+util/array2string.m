function output = array2string( values, format, varargin )

    if nargin < 2 || isempty(format), format='default'; end

    % parse options
    opt = dk.obj.kwArgs( varargin{:} );

        numFmt   = opt.get( 'num', '%g' ); % format used to print numeric values
        rowNames = opt.get( 'row', {} );
        colNames = opt.get( 'col', {} );
    
    % Parse values into a cell
    if isnumeric(values) || islogical(values)
        
        assert( ismatrix(values), 'Sorry, multidimensional arrays are not supported.' );
        V = arrayfun( @(x) dk.util.to_string(x,numFmt), values, 'UniformOutput', false );
        
    elseif iscell(values)
        
        assert( ismatrix(values), 'Sorry, multidimensional arrays are not supported.' );
        V = cellfun( @(x) dk.util.to_string(x,numFmt), values, 'UniformOutput', false );
        
    elseif istable(values)
        
        rowNames = values.Properties.RowNames;
        colNames = values.Properties.VariableNames;
        output   = jh.util.array2string( table2array(values), format, rowNames, colNames );
        return;
        
    else
        error('Unknown array format.');
    end
    
    % Dimensions
    [nr,nc] = size(V);
    
    % Add columns
    if ~isempty(colNames)
        switch lower(format)
            case {'default','latex','tex'}
                V = vertcat( reshape(colNames,[1,nc]), V );
                rowpad = {''};
            case {'markdown','md'}
                V = vertcat( reshape(colNames,[1,nc]), ...
                    arrayfun( @(x) '--', 1:nc, 'UniformOutput', false ), V );
                rowpad = {'';'--'};
        end
    end
    
    % Add rows
    if ~isempty(rowNames)
        rowNames = reshape(rowNames,[nr,1]);
        if ~isempty(colNames)
            rowNames = vertcat( rowpad, rowNames );
        end
        V = horzcat( rowNames, V );
    end
    
    % Update dimensions
    [nr,nc] = size(V);
    
    % Set separators depending on the format
    switch lower(format)
        
        case {'default'}
            sep.beg = ' ';
            sep.val = ', ';
            sep.row = '; ';
            
        case {'latex','tex'}
            sep.beg = ' ';
            sep.val = ' & ';
            sep.row = ' \\';
            
        case {'markdown','md'}
            sep.beg = ' | ';
            sep.val = ' | ';
            sep.row = ' | ';
            
    end
    
    % Allocate output string
    widths = cellfun(@length,V);
    colwid = max(widths,[],1);
    
    stride = colwid + length(sep.val);
    stride = 1+length(sep.beg)+[0,cumsum(stride)];
    stride(end) = stride(end) + length(sep.row)-length(sep.val);
    
    output = repmat( ' ', [nr,stride(end)] );
    
    % Fill columns one by one
    output(:,1:length(sep.beg) ) = repmat( sep.beg, [nr,1] );
    output(:,(end-length(sep.row)):(end-1) ) = repmat( sep.row, [nr,1] );
    
    for c = 1:nc
        for r = 1:nr
            w = widths(r,c);
            output( r, stride(c)+(0:w-1) ) = V{r,c};
        end
        
        if c < nc
            output(:,(stride(c)+colwid(c)):(stride(c+1)-1) ) = repmat( sep.val, [nr,1] );
        end
    end

end

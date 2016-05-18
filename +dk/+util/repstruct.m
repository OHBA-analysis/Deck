function s = repstruct( fields, varargin )
    
    n = numel(fields);
    f = cell(1,2*n);
    f(1:2:end) = fields;

    s = repmat( struct(f{:}), varargin{:} );
    
end
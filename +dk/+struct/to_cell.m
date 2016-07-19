function c = to_cell( s, recursive )
%
% c = dk.struct.to_cell( s, recursive=false )
%
% Build a cell{ key, value } from a structure.
% Structure-arrays are not supported, but the script won't fail if the recursive flag is on, 
% and one of the values is a struct-array (it will just return the struct-array without conversion).
%
% Contact: jhadida [at] fmrib.ox.ac.uk
    
    assert( numel(s) == 1, 'Structure arrays not allowed.' );
    if nargin < 2, recursive = false; end
    
    f  = fieldnames(s);
    nf = length(f);
    c  = cell(1,2*nf);
    
    for i = 1:nf
        
        c{2*i-1} = f{i};
        c{2*i  } = s.( f{i} );
        
        if recursive && isstruct(c{2*i}) && numel(c{2*i}) == 1
            c{2*i} = dk.struct.to_cell( c{2*i} );
        end
        
    end
    
end

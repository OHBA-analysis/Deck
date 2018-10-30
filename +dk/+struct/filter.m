function out = filter(in,varargin)
%
% out = dk.struct.filter(in, field1, field2, ...)
%
% Filter specified fields from input structure s.
% Works with struct-arrays.
%
% JH

    f = dk.unwrap(varargin);
    n = numel(f);
    
    assert( iscellstr(f), 'Fieldnames should be strings.' );
    assert( isstruct(in), 'First input should be a structure.' );
    
    out = cell([ numel(f), numel(in) ]);
    for i = 1:n
        [out{i,:}] = in.(f{i});
    end
    out = cell2struct( out, f(:), 1 );
    out = reshape( out, size(in) );

end
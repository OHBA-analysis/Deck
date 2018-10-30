function s = extract( s, varargin )
%
% s = extract( s, field1, field2, ... )
%
% Remove all but specified fields from input structure s.
% Works with struct-arrays.
%
% JH

    x = dk.unwrap(varargin);
    s = rmfield( s, setdiff( fieldnames(s), x ) );

end
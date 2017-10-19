function y = struct( x, fields, scalar )
%
% y = dk.is.struct( x, fields={}, scalar=true )
% 
% Checks whether input is a structure with specified fields.
% scalar flag can be used to check that it is scalar (ie, not a struct-array).
% 
% fields can be a string or a cell of strings.
% If fields is empty, then fields are not checked.
%
% JH

    if nargin < 2, fields = {}; end
    if nargin < 3, scalar = true; end

    y = isstruct(x);
    
    if ~isempty(fields)
        y = y && all(isfield(x,fields));
    end
    
    if scalar
        y = y && isscalar(x);
    end
    
end
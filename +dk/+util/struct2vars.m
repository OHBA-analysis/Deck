function varargout = struct2vars( s, varname_handle )
%
% Turn the fields of a structure into variables with the same names.
% For instance:
%   a = struct('foo',1,'bar','baz');
%   struct2vars( a );
%
% will create variables foo=1 and bar='baz' in the caller's scope.
% The second argument (function handle), can be used to process the
% variables' name. For instance:
%   struct2vars( a, @(x) ['tmp_' x] );
%
% will create variables tmp_foo and tmp_bar instead.
%

    if nargin < 2, varname_handle = @(x) x; end
    
    % get input variable name
    s_name = inputname(1);
    assert( ~isempty(s_name), 'Unnamed variables (ie temporaries) are not supported.' );
    
    % extract inputs fields
    fields = fieldnames(s);
    n = numel(fields);
    
    % for each field, append the corresponding variable assignment
    eval_str = '';
    for i = 1:n
        field    = fields{i};
        vname    = varname_handle(field);
        eval_str = [eval_str, vname '=' s_name '.' field '; ' ];
    end
    
    if nargout > 0
        varargout{1} = eval_str;
    else
        evalin( 'caller', eval_str );
    end
    
end

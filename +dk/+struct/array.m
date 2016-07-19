function sa = array( varargin )
%
% Example: 
%   a = dk.struct.array( 'foo.bar', [1 2 3], 'baz', {[0 1], 'hello', struct()} )
%   cellfun( @(x) x.bar, {a.foo} )
%   {a.baz}
%
% JH

    % extract fields and values
    assert( mod(nargin,2) == 0, 'Inputs should be key/values pairs.' );
    
    nf     = nargin / 2; % number of fields
    fields = varargin(1:2:end);
    values = varargin(2:2:end);

    % make sure there are the same number of values for each field
    sizes = cellfun( @numel, values );
    if nf > 1, assert( all(diff(sizes) == 0), 'Values should have the same size for each field.' ); end
    ns = sizes(1); % number of structures
    
    % create empty structure to allocate output
    mock = struct();
    for i = 1:nf
        f    = dk.util.string2substruct(fields{i});
        mock = subsasgn( mock, f, [] );
    end
    
    % allocate output and assign values for each field
    sa = repmat( mock, ns, 1 );
    for i = 1:nf
        f = dk.util.string2substruct(fields{i});
        
        if iscell(values{i})
            for j = ns:-1:1, sa(j) = subsasgn( sa(j), f, values{i}{j} ); end
        else
            for j = ns:-1:1, sa(j) = subsasgn( sa(j), f, values{i}(j) ); end
        end
    end
    
end

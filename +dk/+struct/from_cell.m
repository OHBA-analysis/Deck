function s = from_cell( varargin )
%
% s = dk.struct.from_cell( key1, val1, ... )
% s = dk.struct.from_cell( s, key1, val1, ... )
%
% Build a structure from the inputs, in a way that is resistant to:
%   - duplicate fieldnames (last overwrites first)
%   - cell-values, which normally expand into struct-arrays in Matlab
%
% In addition, it can combine an initial structure with additional fields.
% This is similar, though not equivalent, to merging.
%
% Finally, it also plays well with struct-arrays, and is able to add fields
% to an initial struct-array too.
%
% This is basically equivalent to:
%   struct(varargin{:})
% but without the hassles regarding duplicate and cell-valued fields.
%   
% JH

    args = dk.unwrap(varargin);
    nargs = numel(args);
    
    % if unwrapped value is a struct (or struct-array), return that
    if isstruct(args)
        s = args;
        return;
    end
    
    % otherwise, we expect a cell
    assert( iscell(args), 'Expected a struct or cell in input.' );
    if dk.is.even(nargs)
        assert( iscellstr(args(1:2:end)), 'Inputs should be key/value pairs.' );
        k = 1;
        s = struct();
    else
        assert( isstruct(args{1}), 'Bad number of inputs.' );
        assert( iscellstr(args(2:2:end)), 'Input should be key/value pairs.' );
        k = 2;
        s = varargin{1};
    end
    
    % assign additional fields ...
    n = numel(s);
    while k < nargs
        if n > 1
            % ... to struct-array
            [s.(args{k})] = dk.deal(args{k+1});
        else
            % ... to scalar struct
            s.(args{k}) = args{k+1};
        end
        k = k+2;
    end

end
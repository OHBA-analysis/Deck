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
% This is basically equivalent to:
%   struct(varargin{:})
% but without the hassles regarding duplicate and cell-valued fields.
%   
% JH

    args = dk.unwrap(varargin);
    nargs = numel(args);
    
    if dk.is.even(nargs)
        assert( iscellstr(varargin(1:2:end)), 'Inputs should be key/value pairs.' );
        k = 1;
        s = struct();
    else
        assert( isstruct(varargin{1}), 'Bad number of inputs.' );
        assert( iscellstr(varargin(2:2:end)), 'Input should be key/value pairs.' );
        k = 2;
        s = varargin{1};
    end
    
    while k < nargs
        s.(args{k}) = args{k+1};
        k = k+2;
    end

end
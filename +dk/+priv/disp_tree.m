function disp_tree(T,fh)
%
% Display a tree in the console, or write to a file.
%
% OPTIONS:
%
%   fh  File-handle for printing
%

    if nargin < 2, fh=1; end

    [~,remap] = T.indices();
    obj.remap = remap;
    obj.depth = T.depths();
    obj.children = T.childrens();
    obj.print = @(fmt,varargin) fprintf( fh, [fmt '\n'], varargin{:} );

    recurse( obj, 1, '', false, true );

end

function recurse(obj,id,padding,isLast,isFirst)

    %u2n = @(x) native2unicode( x, 'UTF-8' );
    %pad = struct( 'leg', u2n('├── '), 'end', u2n('└── '), 'tab', '   ' );
    pad = struct( 'leg', '├── ', 'end', '└── ', 'tab', '   ' );

    tmp = padding(1:end-1);
    if isFirst
        leg = '';
    elseif isLast
        leg = pad.end;
    else
        leg = pad.leg;
    end

    k = obj.remap(id);
    depth = obj.depth(k);
    children = obj.children{k};
    nchildren = numel(children);

    obj.print( '%s:%d +%d %d', [tmp leg], depth, nchildren, id );

    if ~isFirst
        padding = [padding pad.tab];
    end
    for c = 1:nchildren
        isLast = c == nchildren;
        if isLast
            recurse( obj, children(c), [padding ' '], isLast, false );
        else
            recurse( obj, children(c), [padding '|'], isLast, false );
        end
    end

end
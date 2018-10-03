function p = clearpath( varargin )
%
% p = dk.env.clearpath( varargin )
%
% Remove all existing entries in the path which start with specified folders.
%
% If NO output is collected, then the Matlab path is updated.
% If an output is collected, the the path is not affected.
%
% JH

    % list folders to filter
    folders = unique(varargin);
    assert( iscellstr(folders), 'Input folders should be strings.' );
    
    % current path
    p = strsplit( path, pathsep );
    p = p(~contains( folders, p ));
    
    % modify path if not output
    if nargout == 0
        path(strjoin( p, pathsep ));
    end

end

function out = contains( folders, data )

    out = false(size(data));
    n = numel(folders);
    
    for i = 1:n
        out = out | dk.mapfun( @(v) any(v==1), strfind( data, folders{i} ), true );
    end

end
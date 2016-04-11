function folders = list_folders( dirname, pattern )
%
% List folders in dirname matching the input pattern (default: non-hidden).
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 2, pattern = '^[^\.].*'; end

    folders = dk.fs.list_match( dirname, pattern, @dk.fs.is_dir );
    
end

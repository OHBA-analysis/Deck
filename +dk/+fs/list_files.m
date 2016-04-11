function files = list_files( dirname, pattern )
%
% List files in dirname matching pattern (default: non-hidden).
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 2, pattern = '^[^\.].*'; end

    files = dk.fs.list_match( dirname, pattern, @dk.fs.is_file );

end

function files = list( dirname )
%
% List everything in dirname, except names beginning with a dot (hidden).
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    files = dk.fs.list_match( dirname, '^[^\.].*' );
end

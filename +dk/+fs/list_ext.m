function files = list_ext( dirname, ext )
%
% List files by extension in directory dirname.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    files = dk.fs.list_match( dirname, ['^\w+\.' ext '$'] );
end

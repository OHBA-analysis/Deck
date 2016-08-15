function save( filename, data, ubflag, rootname, varargin )

    if nargin < 4, rootname=''; end

    if nargin > 2 && all(logical(ubflag))
        dk.json.priv.saveubjson( rootname, data, 'FileName', filename, varargin{:} );
    else
        dk.json.priv.savejson( rootname, data, 'FileName', filename, varargin{:} );
    end

end
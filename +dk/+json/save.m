function save( filename, data, ubflag, rootname )

    if nargin < 4, rootname='root'; end

    if nargin > 2 && all(logical(ubflag))
        dk.json.priv.saveubjson( rootname, data, filename );
    else
        dk.json.priv.savejson( rootname, data, filename );
    end

end
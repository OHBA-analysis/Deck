function data = load( filename, ubflag, rootname )

    if nargin < 3, rootname='root'; end

    if nargin > 1 && all(logical(ubflag))
        data = dk.json.priv.loadubjson( filename );
    else
        data = dk.json.priv.loadjson( filename );
    end
    data = data.(rootname);

end
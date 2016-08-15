function data = load( filename, ubflag, rootname, varargin )

    if nargin < 3, rootname=''; end

    if nargin > 1 && all(logical(ubflag))
        data = dk.json.priv.loadubjson( filename, varargin{:} );
    else
        data = dk.json.priv.loadjson( filename, varargin{:} );
    end
    if ~isempty(rootname)
        data = data.(rootname);
    end

end
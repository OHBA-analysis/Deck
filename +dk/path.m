function d = path(varargin)
    d = fileparts(mfilename('fullpath'),varargin{:});
end

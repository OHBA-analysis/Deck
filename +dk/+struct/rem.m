function s = rem( s, varargin )
%
% Remove a field value from a structure if the field exists.
% If not, don't throw an error.

    if nargin == 2 && iscellstr(varargin{1})
        f = intersect( fieldnames(s), varargin{1} );
    else
        f = intersect( fieldnames(s), varargin );
    end
    try
        s = rmfield(s,f);
    catch
        % do nothing
    end

end

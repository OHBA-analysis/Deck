function s = set_field( s, fname, value )
%
% Set a field value in a structure if it is not set.

    if ~isfield(s,fname)
        n = numel(s);
        
        if isscalar(value)
            for i = 1:n, s.(fname) = value; end
        elseif numel(value) == n
            if iscell(value)
                for i = 1:n, s.(fname) = value{i}; end
            else
                for i = 1:n, s.(fname) = value(i); end
            end
        else
            error('Dont know how to do this assignment.');
        end
    end

end

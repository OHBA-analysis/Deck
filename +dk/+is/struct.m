function y = struct( x, scalar )

    if nargin < 2, scalar = true; end

    y = isstruct(x);
    if scalar
        y = y && isscalar(x);
    end
    
end
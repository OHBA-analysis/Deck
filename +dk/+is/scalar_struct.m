function y = scalar_struct(x)
    y = isstruct(x) && isscalar(x);
end
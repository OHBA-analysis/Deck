function y = empty_struct(x)
    y = isstruct(x) && isempty(fieldnames(x));
end
function print_as_cpp_array( values, fmt, width )

    if nargin < 3, width = 10; end

    n = numel(values);
    fprintf(['{ ' fmt], values(1));
    for i = 2:n
        
        if mod(i,width) == 1
            fprintf([',\n  ' fmt], values(i));
        else
            fprintf([', ' fmt], values(i));
        end
        
    end
    fprintf(' };\n');

end
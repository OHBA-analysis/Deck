function [index,value] = find_closest( query, data )

    [~,index] = min(abs( data(:) - query ));
    value     = data(index);

end

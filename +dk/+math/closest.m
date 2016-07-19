function [index,value] = closest( query, data, distfun )

    if nargin < 3, distfun = @(a,b) abs(a(:)-b(:)); end

    [~,index] = min(distfun( data, query ));
    value     = data(index);

end

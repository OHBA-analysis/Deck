function Y = rescale( X, range, method )

    if nargin < 2, range = [0 1]; end
    if nargin < 3, method = 'linear'; end
    
    xmin = min(X(:));
    xmax = max(X(:));
    
    m = range(1);
    M = range(2);
    
    switch lower(method)
    
        case 'linear'
            Y = m + (M-m)*(X-xmin)/max( xmax-xmin, eps );
            
        otherwise
            error('Unknown method "%s".',method);
        
    end
    
end

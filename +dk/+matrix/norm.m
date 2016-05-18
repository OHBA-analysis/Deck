function vals = norm( mats, name, varargin )

    % select norm
    switch lower(name)
        
        case {'fro','frobenius'}
            f = @(x) norm(x,'fro');
            
        case {'lp'}
            f = @(x) norm(x,varargin{1});
            
        case {'amedian'}
            f = @(x) median(abs(x(:)));
            
        case {'amedian_nodiag'}
            f = @(x) median(abs(x( ~eye(size(x),'logical') )));
            
        otherwise
            error('Unknown norm "%s".',name);
        
    end
    
    % apply norm
    n = size(mats,3);
    vals = zeros(1,n);
    
    for i = 1:n
        vals(i) = f(mats(:,:,i));
    end

end
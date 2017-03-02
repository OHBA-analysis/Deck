function [dx,ck] = diff( x, h, dim, horizon, tangency )
%
% [dx,ck] = diff( x, h, dim, horizon=4, tangency=4 )
%
% Numerical differentiation of sampled sequence.
%
% Example:
%     t = linspace(-2,13,400); 
%     h = t(2)-t(1); 
%     x = sin(t); 
%     y = dk.math.diff( x, h );
%     plot(t,x,t,y);
%
% See: 
% http://www.holoborodko.com/pavel/numerical-methods/numerical-derivative/smooth-low-noise-differentiators/
%
% JH
    
    if nargin < 5, tangency=4; end
    if nargin < 4, horizon=4; end
    if nargin < 3 || isempty(dim)
        [~,shift] = shiftdim(x); 
        dim = shift+1;
    else
        shift = dim-1;
    end
    if nargin < 2, h=1; end

    N = 2*horizon+1;
    M = horizon;
    
    switch tangency
        
        % second-order tangency
        case 2
            
            switch horizon
                case 2
                    ck = [2,1]/8;
                case 3
                    ck = [5,4,1]/32;
                case 4
                    ck = [14,14,6,1]/128;
                case 5
                    ck = [42,48,27,8,1]/512;
                otherwise
                    error('General formula for second-order tangency not implemented yet.');
                    % TODO: use generalised binomial coefficients..
                    m = (N-3)/2;
                    ck = zeros(1,M);
                    for k = 1:M
                        ck(k) = ( nchoosek(2*m,m-k+1) - nchoosek(2*m,m-k-1) )/pow2(2*m+1);
                    end
            end
            
        % fourth-order tangency
        case 4
            
            switch horizon
                case 3
                    ck = [39,12,-5]/96;
                case 4
                    ck = [27,16,-1,-2]/96;
                case 5
                    ck = [322,256,39,-32,-11]/1536;
                otherwise
                    error('No general formula for fourth-order tangency.');
            end
            
        otherwise
            error('Unsupported tangency.');
        
    end
    
    a = size(x,dim);
    b = numel(x)/a;
    S = circshift( size(x), [0,shift] );
    
    ck = [-fliplr(ck),0,ck]/h;
    dx = reshape(shiftdim(x,shift),[a,b]);
    %dx = conv2( padarray(dx,[M,0],'replicate'), flipud(ck(:)), 'valid' );
    dx = conv2( wextend('ar','sp1',dx,M), flipud(ck(:)), 'valid' );
    dx = shiftdim(reshape(dx,S),-shift);

end
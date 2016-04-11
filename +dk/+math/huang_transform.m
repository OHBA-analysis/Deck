function [imfs,status] = huang_transform( data, varargin )

    % parse options
    opt = dk.obj.kwArgs(varargin{:});
    
        opt_sd_thresh  = opt.get( 'sd_thresh', 0.25 );
        opt_max_imf    = opt.get( 'max_imf', 200 );
        opt_min_energy = opt.get( 'min_energy', 1e-6 );
        opt_taper      = opt.get( 'taper', 0.25 );
    
    % allocate memory
    data = data(:);
    data = data .* tukeywin(numel(data),opt_taper); % bohanwin or chebwin could be alternatives
    imfs = cell(1,opt_max_imf);
    iter = 0;
    
    % iterative mode extraction
    while true
        
        % initialisation
        iter = iter+1;
        sd   = inf;
        h1   = data;
        
        % iterative sifting
        while (sd > opt_sd_thresh) || ~is_imf(h1)
            
            h2 = do_sift(h1);
            sd = sum( (h1-h2).^2 ) / sum(h1.^2);
            h1 = h2;
            
        end
        imfs{iter} = h1;
        
        % iteration check
        if iter == opt_max_imf
            status.msg = 'Reached the maximum number of iterations.';
            break;
        end
        
        % energy check
        data = data - h1;
        if sum(data.^2) <= opt_min_energy
            status.msg = 'Residue energy is below threshold.';
            break;
        end
        
    end
    
    % sort imfs
    imfs = fliplr(horzcat( imfs{1:iter} ));
    
    % status
    status.n_iter = iter;
    
end

function [lmin,lmax] = local_extrema( x )

    dx = diff(x,1,1);
    zc = [dx(1:end-1) .* dx(2:end) <= 0; 1];
    le = [ -dx(1); zc .* dx ];
    
    lmin = find( le < 0 );
    lmax = find( le > 0 );

end

function yes = is_imf( h )
    
    % find local extrema
    [lmin,lmax] = local_extrema(h);
    
    nle = length(lmin) + length(lmax); % # of local extrema
    nzc = sum( h(1:end-1) .* h(2:end) < 0 ); % # of zero-crossings
    yes = nle <= 3 || abs( nzc - nle ) <= 2;
    
end

function h = do_sift( x )

    n = numel(x);
    t = transpose(1:n);

    % local extrema
    [lmin,lmax] = local_extrema(x);
    
    % we need at least 4 points (2 min, 2 max) to interpolate
    if length(lmin) + length(lmax) <= 3
        h = x;
        return;
    end
    
    % min and max envelopes (cubic interpolation)
    emin = interp1( lmin, x(lmin), t, 'pchip' );
    emax = interp1( lmax, x(lmax), t, 'pchip' );
    
    % do the sift
    m = (emin + emax) / 2;
    h = x - m;
    
end

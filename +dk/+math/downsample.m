function [y, ty]  = downsample( x, tx, fs, win )
%
% [y, ty] = dk.math.downsample( x, tx, fs, method=pchip )
%
% Downsample a time-series using sliding-window.
%
% JH

    PREC = @(a,b) floor(log10(max(a,b))) - floor(log10(abs( a-b )));
    
    if nargin < 4, win = 'tukey'; end
    
    [x,tx] = dk.util.format_ts(x,tx,'vertical');
    
    % make sure input is sampled arithmetically
    dt = diff(tx);
    assert( all(dt > eps), 'Input is non-analytic.' );
    assert( (max(dt)/mean(dt) -1) <= 1e-3, 'Input time-step is not steady.' );
    dt = mean(dt);
    
    % check that fs is greater than current sampling rate
    newdt = 1/fs;
    if abs(newdt-dt) < eps, y=x; ty=tx; return; end
    assert( newdt > dt, 'Requested sampling rate is higher than current one, use dk.math.upsample instead.' );
    
    % save last timepoint
    tlast = tx(end);
    xlast = x(end,:);
    
    % frequency discrepancy caused by integer step matching
    target_fs = fs;
    actual_fs = 1 / ( dt * ceil(newdt/dt) );
    
    % if too large, upsample to a suitable rate before downsampling
    if PREC(actual_fs,target_fs) < 2 % the two MSD must be equal
        dk.info('[dk.math.downsample] Upsampling before downsampling to correct for frequency discrepancy.');
        newdt  = newdt / ceil(newdt/dt);
        [x,tx] = dk.math.upsample( x, tx, 1/newdt );
    end
    
    % compute sliding parameters
    wstep = ceil( 1/dt/fs );
    wsize = 3*wstep;
    nwin  = 1 + floor( (size(x,1) - wsize)/wstep );
    
    % prepare window
    wy = dk.math.window( win, wsize );
    wy = wy(:)' / sum(wy);
    wt = ones(1,wsize) / wsize;
    
    % allocate output
    t = zeros( nwin, 1 );
    y = zeros( nwin, size(x,2) );
    
    for w = 1:nwin
        b = 1 + (w-1)*wstep;
        e = b + wsize-1;
        
        t(w)   = wt * tx(b:e);
        y(w,:) = wy * x( b:e, : );
    end
    
    % interpolate to final precision
    ty = colon( tx(1), 1/fs, tx(end) )';
    y  = interp1( [tx(1); t; tlast], [x(1,:); y; xlast], ty, 'pchip' );
    
end
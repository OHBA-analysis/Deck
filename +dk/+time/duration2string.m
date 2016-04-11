function str = duration2string( duration )
%
% Pretty string-conversion of a duration.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    dcell              = num2cell(duration);
    [ d, h, m, s, ms ] = deal(dcell{:});

    if any( isinf(duration) | isnan(duration) )
        str = '<undefined>';
    elseif (d > 0 )
		str = sprintf( '%u days and %02uh %02umin %02usec', d, h, m, s );
    elseif ( h > 0 )
		str = sprintf( '%uh %02umin %02usec', h, m, s );
    elseif ( m > 0 )
		str = sprintf( '%umin %02usec', m, s );
    elseif ( s > 0 || ms > 0 )
		str = sprintf( '%u.%03u sec', s, ms );
    else
        str = '<null>';
    end
    
end

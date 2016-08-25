function [dist,xtic] = distplot( data, wid )

    % maximum width of the distribution for each column
    if nargin < 2, wid = 0.7; end

    % colors used for drawing
    color.box = hsv2rgb([30/360 1 0.9]); % orange
    color.med = hsv2rgb([30/360 1 0.1]); % black
    color.avg = hsv2rgb([200/360 1 0.9]/100); % blue

    % number of columns
    if iscell(data)
        nd = numel(data);
    else
        nd = size(data,2);
    end
    
    % compute and draw distributions
    dist = cell(1,nd);
    step = ceil(wid);
    xtic = 0.5 + step * (0:nd-1);
    
    q99 = -Inf;
    q01 =  Inf;
    
    for i = 1:nd
        [dist{i},v] = distribution( data, i );
        plot_distribution( dist{i}, xtic(i), wid, color );
        
        q99 = max( q99, prctile(v,99) );
        q01 = min( q01, prctile(v,1) );
    end
    
    % adjust y-axis limits
    q99 = 1.1*q99;
    q01 = 0.9*q01;
    
    % prevent drawing over, and set tick labels
    hold off; ylim([q01 q99]);
    set(gca,'xtick',xtic,'xticklabel',dk.arrayfun(@num2str,1:nd,false));
    
    % concatenate distributions as a struct array
    dist = [dist{:}];

end

function [dist,v] = distribution( dat, k )

    if iscell(dat)
        v = dat{k}(:);
    else
        v = dat(:,k);
    end

    [dist.y,dist.x] = ksdensity(v,[],'NumPoints',50);
    dist.m = median(v);
    dist.a = mean(v);
    
end

function h = plot_distribution( dist, loc, wid, col )

    x = (wid/2) * dist.y / max(dist.y);
    x = [ loc + x, loc - fliplr(x) ];
    y = [ dist.x, fliplr(dist.x) ];
    h.d = fill( x, y, col.box, 'EdgeColor', 'none' ); 
    hold on;
    
    mw = interp1( dist.x, dist.y, dist.m );
    mw = (wid/2) * mw / max(dist.y);
    h.m = plot( loc+mw*[-1,1], dist.m*[1,1], '-', 'Color', col.med, 'LineWidth', 2 );

    %h.a = plot( loc, dist.a, '+', 'Color', col.avg, 'MarkerSize', 7 );
    %h.a = plot( loc, dist.a, 'r+' );
    
end
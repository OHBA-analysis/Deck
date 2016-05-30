function [dist,xtic] = distplot( data, wid )

    % maximum width of the distribution for each column
    if nargin < 2, wid = 0.7; end

    % colors used for drawing
    color.box = hsv2rgb([30/360 1 0.9]); % orange
    color.med = hsv2rgb([30/360 1 0.1]); % black
    color.avg = hsv2rgb([200/360 1 0.9]/100); % blue

    % number of columns
    nd = size(data,2);
    
    % compute and draw distributions
    dist = cell(1,nd);
    step = ceil(wid);
    xtic = step * (0.5 : 1 : nd);
    
    for i = 1:nd
        dist{i} = distribution( data(:,i) );
        plot_distribution( dist{i}, xtic(i), wid, color );
    end
    
    % prevent drawing over, and set tick labels
    hold off; set(gca,'xtick',xtic,'xticklabel',arrayfun(@num2str,1:nd,'UniformOutput',false));
    
    % concatenate distributions as a struct array
    dist = [dist{:}];

end

function dist = distribution( x )

    [dist.y,dist.x] = ksdensity(x,[],'NumPoints',50);
    dist.m = median(x);
    dist.a = mean(x);
    
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
    
end
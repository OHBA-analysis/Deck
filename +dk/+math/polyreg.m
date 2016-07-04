function coef = polyreg( x, y, n, doplot )
%
% Fits polynomial of degree n to input data.
% Returns n+1 coefficients sorted from the highest power down. 
%
% JH

    if nargin < 3 || isempty(n), n = 1; end
    
    % format data suitably
    [x,o] = sort(x(:));
    y = y(o);
    
    % run polyfit estimation
    coef = polyfit( x, y, n );
    
    % plot results
    if nargin < 4, doplot = nargout == 0; end
    if doplot
        
        scatter( x, y, 'bo' ); hold on;
        t = linspace(x(1),x(end),300);
        plot( t, polyval( coef, t ), 'r-', 'LineWidth', 3 ); hold off;
        title(sprintf( 'Polynomial regression (degree %d)', n ));
        legend( 'Original data', 'Regression' );
        
    end
    
end
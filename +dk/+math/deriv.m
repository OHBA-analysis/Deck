function df = deriv( f, x, h )
% df = deriv( f, x, h )
%
% f: scalar function handle
% x: point at which the gradient is computed
% h: numeric step for central approx
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 3, h = 1e-6; end
    df = ( f(x+h) - f(x-h) ) / (2*h);
end

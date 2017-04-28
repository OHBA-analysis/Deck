function h = ring( Rin, Rout, C, npts, col, varargin )
%
% h = dk.ui.ring( inner, outer, centre=[0 0], npts=51, col='k', varargin )
%
% Draw a ring with specified inner and outer radii, at the centre provided.
% Additional arguments are forwarded to patch, and the output is a handle to the patch.
%
% JH

    if nargin < 3 || isempty(C), C=[0 0]; end
    if nargin < 4 || isempty(npts), npts=51; end
    if nargin < 5 || isempty(col), col='k'; end

    t = linspace( 0, 2*pi, npts );
    u = fliplr(t);
    
    x = [ Rout, Rin*cos(t), Rout*cos(u) ];
    y = [ 0, Rin*sin(t), Rout*sin(u) ];
    
    h = fill( C(1)+x, C(2)+y, col, varargin{:} );

end
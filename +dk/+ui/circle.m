function h = circle( R, C, npts, varargin )
%
% h = dk.ui.circle( radius, centre=[0 0], npts=51, varargin )
%
% Draw a circle with specified centre and radius.
% Additional arguments are forwarded to plot, and the output is a handle to the plot.
%
% JH

    if nargin < 2 || isempty(C), C=[0 0]; end
    if nargin < 3 || isempty(npts), npts=51; end

    t = linspace(0,2*pi,npts);
    h = plot( C(1)+R*cos(t), C(2)+R*sin(t), varargin{:} );

end
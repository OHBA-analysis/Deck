function disp( fmt, varargin )
%
% dk.disp( fmt, varargin )
%
% Formatted display, equivalent to:
%   fprintf( [fmt '\n'], varargin{:} );
%
% JH

    fprintf( [fmt '\n'], varargin{:} );
end

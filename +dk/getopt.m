function out = getopt( args, varargin )
%
% out = dk.getopt( args, varargin )
%
% Simple script to extract named options with defaults.
%
% NOTE:
%   Option names are case-sensitive
%   Duplicate input options are fine (overwrite left)
%   Duplicate defaults cause an error
%
% EXAMPLE:
%
%   function [...] = foo( a, b, c, varargin )
%
%       opt = dk.getopt( varargin, 'alpha', 0.5 );
%       disp( opt.alpha );
%
%
% See also: dk.obj.kwArgs
% 
% JH

    out = dk.c2s( varargin );
    n = numel(args);
    if n == 1
        assert( dk.is.struct(args), 'Scalar input should be a struct.' );
        out = dk.struct.merge( out, args );
    else
        assert( dk.is.even(n), 'Input args should be key/value pairs.' );
        for i = 1:2:n
            out.(args{i}) = args{i+1};
        end
    end

end
function y = square( varargin )
% square matrix
    y = dk.cellfun( @(x) ismatrix(x) && diff(size(x))==0, varargin, true );
end
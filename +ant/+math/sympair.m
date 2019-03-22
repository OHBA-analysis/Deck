function z = sympair( i, j )
%
% z = ant.math.sympair( i, j )
%
% Symmetric pairing function; map pairs of input indices to unique integer.
% This mapping was derived from the row-major indexing scheme.
% 
% JH

    z = min(i,j);
    i = max(i,j);
    z = z + i.*(i-1)/2;
    
end

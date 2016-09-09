function y = squaremat( x )
% square matrix
    y = ismatrix(x) && diff(size(x))==0;
end
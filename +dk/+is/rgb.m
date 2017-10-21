function y = rgb( c )
%
% y = dk.is.rgb( c )
%
% Checks input is a valid RGB vector.
%
% JH

    y = isnumeric(c) && (numel(c)==3 || size(c,2)==3) && all(dk.math.is_between( c(:), 0, 1 ));

end
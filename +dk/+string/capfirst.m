function str = capfirst( str, lower_other )
%    
% Run singlespaces and capitalise the first letter.
% If option lower_other is true, other letters are forced to lower font (default not).

    if nargin < 2, lower_other = false; end

    str = dk.string.singlespaces(str);
    str(1) = upper(str(1));
    
    if lower_other
        str(2:end) = lower(str(2:end));
    end
    
end
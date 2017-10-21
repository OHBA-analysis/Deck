function y = is_between( val, lo, hi, bc )
%
% y = dk.math.is_between( val, lo, hi, bc='[]' )
%
% Checks whether input value is in specified range, with optional boundary condition.
% Valid conditions are:
%   open, ()
%   closed, []
%   [), (]
%
% JH
    
    if nargin < 4, bc = '[]'; end
    
    switch bc
        
        case {'open','()'}
            y = (val > lo) & (val < hi);
            
        case {'closed','[]'}
            y = (val >= lo) & (val <= hi);
            
        case '[)'
            y = (val >= lo) & (val < hi);
            
        case '(]'
            y = (val > lo) & (val <= hi);
            
        otherwise
            error('Boundary condition should be one of "[]", "[)", "()", "(]".' );
        
    end
    
end

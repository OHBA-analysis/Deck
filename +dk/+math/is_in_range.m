function y = is_in_range( val, lo, hi, bc )
    
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

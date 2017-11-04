function out = mapfun( fun, val, unif )
%
% out = dk.mapfun( fun, val, unif=false )
%
% Use cellfun, arrayfun or structfun depending on the type of input.
% Fine not to collect output (in which case no need for fun to return anything).
% 
% JH

    if nargin < 3, unif=false; end
    
    if iscell(val)
        map = @cellfun;
    elseif isscalar(val) && isstruct(val)
        map = @structfun;
    else
        map = @arrayfun;
    end
    
    if nargout == 0
        map( fun, val, 'UniformOutput', unif );
    else
        out = map( fun, val, 'UniformOutput', unif );
    end

end
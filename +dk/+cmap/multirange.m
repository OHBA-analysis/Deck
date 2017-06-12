function mrange = multirange( x, ctype, crange )
%
% mrange = multirange( x, ctype='auto', crange=[] )
%
% Estimate common range for all cells in input data.
% Input x should be a cell.
%
% See also: dk.cmap.range
%
% JH

    assert( iscell(x), '[dk.cmap.multirange] Input data should be a cell.' );
    if nargin < 2, ctype='auto'; end
    if nargin < 3, crange=[]; end

    n = numel(x);
    mrange = nan(1,2);
    
    for i = 1:n
        tmp = dk.cmap.range( x{i}, ctype, crange );
        mrange(1) = min(tmp(1),mrange(1));
        mrange(2) = max(tmp(2),mrange(2));
    end
    
    % final run to honour ctype
    mrange = dk.cmap.range( [], ctype, mrange );

end
function [crange,ctype] = range( x, ctype, crange )
%
% [crange,ctype] = dk.cmap.range( x, ctype='auto', crange=[] )
%
% Infer color range from input data.
% Output:
%   crange  1x2 array with lower/upper bounds
%    ctype  If input as 'auto', output is one of: bisym, pos, neg
%
% JH

    if islogical(x)
        crange = [0,1];
        ctype  = 'bool';
        return;
    end

    assert( isnumeric(x), '[dk.cmap.range] Input data should be numeric.' );
    if nargin < 2, ctype='auto'; end
    if nargin < 3, crange=[]; end
    
    % color range
    if isempty(crange)
        crange = prctile( dk.util.filtnum(x), [1 99] );
    end
    
    % truncate to 2 significant digits
    crange = dk.math.trunc(sort(crange), 2);
    if diff(crange) <= 0
        warning( 'Empty color range (might be too narrow).' );
        crange = [0 1];
    end
    
    % characterise range
    lo = crange(1);
    hi = crange(2);
    if (lo < -eps) && (hi > eps)
        rtype = 0; % range crosses 0
    elseif hi < eps
        rtype = -1; % both negative
    else
        rtype = 1;
    end
    
    % automatic type deduction
    if strcmpi( ctype, 'auto' )
        switch rtype
            case 0
                ctype = 'bisym';
            case 1
                ctype = 'pos';
            case -1
                ctype = 'neg';
        end
    end
    
    % set color-scale
    mg = max(abs(crange));
    switch lower(ctype)
        case {'none','manual'}
            % nothing to do
        case {'pos','positive'}
            if lo < hi/4
                crange = crange .* [0 1]; % force lo to 0
            end
        case {'neg','negative','revneg'}
            if hi > lo/4
                crange = crange .* [1 0]; % force hi to 0
            end
        case {'bisym','sym','symmetric','revsym'}
            crange = mg * [-1 1]; % symmetric
    end
    
end
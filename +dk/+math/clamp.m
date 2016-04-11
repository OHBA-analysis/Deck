function vals = clamp( vals, bvals, cvals )
%
% vals = clamp( vals, bvals, cvals =bvals )
%
% Clamp input values in the range bvals to values cvals.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 3, cvals = bvals; end

    vals( vals < bvals(1) ) = cvals(1);
    vals( vals > bvals(2) ) = cvals(2);
end

function y = empty(varargin)
% Behaves intuitively with struct
    y = cellfun( @do_test, varargin, 'UniformOutput', true );
end

function y = do_test(x)
    if isstruct(x)
        y = isempty(fieldnames(x));
    else
        y = isempty(x);
    end
end
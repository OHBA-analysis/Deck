function v = getelem( X, k, v )

    if numel(X) >= k
    if iscell(X)
        v = X{k};
    else
        v = X(k);
    end
    end
    
end
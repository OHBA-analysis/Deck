function t = modeq(x,n,p)
    try
        t = mod(x,n) == p;
    catch
        t = false;
    end
end
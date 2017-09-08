function [tstat,t] = timeit( nrep, fun, varargin )
% 
% [tstat,t] = timeit( nrep, fun, data )
% 
% Apply function a number of times, measure the execution time,
% and return statistics on these times.
% Optionally provide arguments for the function.
%
% JH
    
    t = zeros(1,nrep); tic;
    for i = 1:nrep
        fun(varargin{:}); 
        t(i) = toc;
    end
    t = diff([0,t]);
    tstat = [mean(t),std(t),median(t)];
end

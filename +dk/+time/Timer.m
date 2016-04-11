classdef Timer < handle
%
% A lightweight timer class using cputime.
% It includes a simple linear estimation of timeleft from the amoung of task done, 
% which is useful to monitor the progress of long tasks.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk
    
    properties (SetAccess = private)
        start_time;
    end
    
    methods
        
        function self = Timer()
            self.start();
        end
        
        function start(self)
            self.start_time = tic;
        end
        
        function t = restart(self)
            t = self.runtime();
            self.start();
        end
        
        % Runtime
        function t = runtime(self)
            t = toc(self.start_time);
        end
        function s = runtime_str(self)
            t = self.runtime();
            s = dk.time.sec2str(t);
        end
        
        % Linear timeleft estimation
        function t = timeleft(self,fraction_done)
            t = self.runtime();
            t = t / fraction_done - t;
        end
        function s = timeleft_str(self,fraction_done)
            t = self.timeleft(fraction_done);
            s = dk.time.sec2str( t );
        end
        
    end
    
end

classdef MEEG_TimeSeries < handle
% 
% Quick and dirty wrapper for MEEG objects behaving as if the first dimension was time.
% That is, as if the dimensions of the D-object were: time x channels x trials
%
% JH
    
    properties 
        dobj;
    end
    
    properties (Transient,Dependent)
        ns, nt, time, tspan;
    end
    
    methods
        
        function self = MEEG_TimeSeries(dobj)
        if nargin > 0
            self.dobj = dobj;
        else
            self.dobj = [];
        end
        end
        
        function n = get.nt(self), n = size(self.dobj,2); end
        function n = get.ns(self), n = size(self.dobj,1); end
        
        function t = get.time(self)
            if isempty(self.dobj)
                t = [];
            else
                t = self.dobj.time(:);
            end
        end
        
        function t = get.tspan(self)
            t = self.time(end) - self.time(1);
        end
        
        function dt = timediff(self,scal,rtol)
            if nargin < 2, scal=false; end
            if nargin < 3, rtol=1e-6; end
            dt = diff(self.time);
            if scal
                assert( max(dt)/mean(dt) < 1+rtol, 'Not regularly sampled' );
                dt = mean(dt);
            end
        end
        
        function varargout = size(self,k)
            
            if nargin > 1
                if     k == 1, k = 2; 
                elseif k == 2, k = 1; end
                s = size(self.dobj,k);
            else
                s = size(self.dobj);
                tmp  = s(2);
                s(2) = s(1);
                s(1) = tmp;
            end
            
            if nargout > 1
                varargout = num2cell(s);
            else
                varargout = {s};
            end
            
        end
        
        function varargout = subsref(self,s)
            
            varargout = cell(1,nargout);
            switch s(1).type
                case '.'
                    if length(s) == 1
                    % Implement obj.PropertyName

                        switch s.subs
                        case 'dobj'
                            varargout = {self.dobj};
                        case 'size'
                            [varargout{:}] = self.size();
                        otherwise
                            [varargout{:}] = builtin('subsref',self.dobj,s); 
                        end

                    else
                        [varargout{:}] = builtin('subsref',self,s);
                    end
                case '()'
                    if length(s) == 1
                    % Implement obj(indices)

                        p = s.subs;
                        if numel(p) > 1
                            tmp  = p{2};
                            p{2} = p{1};
                            p{1} = tmp;
                        end
                        s.subs = p;
                        
                        [varargout{:}] = builtin('subsref',self.dobj,s)';

                    else
                        [varargout{:}] = builtin('subsref',self,s);
                    end
                otherwise
                    error('Not a valid indexing expression');
            end
        
        end
        
    end
    
end
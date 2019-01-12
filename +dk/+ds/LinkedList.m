classdef LinkedList < dk.priv.GrowingContainer
    
    properties
        data
        link
    end
    
    properties (Transient,Dependent)
        numel
    end
    
    methods
        function n = get.numel(self), n = self.count; end
        
        function y = isempty(self)
            y = self.numel() == 0;
        end 
    end
    
    methods
        
        function self = LinkedList(varargin)
            self.clear();
        end
        
        function clear(self)
            self.gcClear();
            self.data = cell(0,1);
            self.link = zeros(0,2);
        end
        
        function reset(self,bsize)
            if nargin < 2, bsize=100; end
            
            self.gcInit(bsize);
            self.data = cell(bsize,1);
            self.link = zeros(bsize,2);
        end
        
        function append(self,vals)
        end
        
        function prepend(self,k,vals)
        end
        
        function remove(self,k)
        end
        
        function insert(self,k,vals)
            
        end
        
    end
    
    methods (Hidden)

        function childAlloc(self,n)
            self.data = vertcat(self.data, cell(n,1));
            self.link = vertcat(self.link, zeros(n,2));
        end

        function childCompress(self,id,remap)
            self.data = self.data(id);
            self.link = remap(self.link(id,:));
        end
        
        function childRemove(self,k)
        end

    end
    
end

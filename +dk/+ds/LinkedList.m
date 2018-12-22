classdef LinkedList < dk.priv.GrowingContainer
    
    properties
        data
        link
    end
    
    properties (Transient,Dependent)
        numel
    end
    
    methods
        
        function self = LinkedList(varargin)
            self.clear();
        end
        
        function n = get.numel(self), n = self.nelm; end
        
        function clear(self)
            self.gcClear();
            self.data = cell(0,1);
            self.link = zeros(0,2);
        end
        
        function y = isempty(self)
            y = self.numel() == 0;
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
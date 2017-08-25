classdef Node < handle
    
    properties (SetAccess = protected)
        data
        parent
        children
        depth
    end
    
    properties (Transient,Dependent)
        is_valid
        is_leaf
        is_empty
        n_children
        fields
    end
    
    methods
        function y=get.is_leaf(self)
            y=isempty(self.children);
        end
        function f=get.fields(self)
            f=fieldnames(self.data);
        end
        function y=get.is_empty(self)
            y=(numel(self.fields) > 0);
        end
        function y=get.is_valid(self)
            y=(self.depth > 0);
        end
        function n=get.n_children(self)
            n=numel(self.children);
        end
    end
    
    methods
        
        function self = Node(varargin)
            self.clear();
            self.assign(varargin{:});
        end
        
        function clear(self)
            self.depth = 0;
            self.parent = [];
            self.children = [];
            self.data = struct();
        end
        
        function self=assign(self,depth,parent,varargin)
            self.depth = depth;
            self.parent = parent;
            if nargin > 3
                if isstruct(varargin{1})
                    self.data = varargin{1};
                else
                    self.data = struct(varargin{:});
                end
            end
        end
        
        function self=add_child(self,c)
            self.children(end+1) = c;
        end
        function self=rem_child(self,c)
            self.children = setdiff(self.children, c);
        end
        
        function self=remap(self,old2new)
            self.parent = old2new(self.parent);
            self.children = old2new(self.children);
            assert( all([self.parent,self.children]), 'Error during remap (null index found).' );
        end
        
    end
    
end
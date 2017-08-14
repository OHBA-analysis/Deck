classdef Node < handle
    
    properties (SetAccess = protected)
        userdat
        parent
        children
        depth
    end
    
    properties (Transient,Dependent)
        is_valid
        is_leaf
        is_empty
        fields
    end
    
    methods
        function y=get.is_leaf(self)
            y=isempty(self.children);
        end
        function f=get.fields(self)
            f=fieldnames(self.userdat);
        end
        function y=get.is_empty(self)
            y=(numel(self.fields) > 0);
        end
        function y=get.is_valid(self)
            y=(self.depth > 0);
        end
    end
    
    methods
        
        function out=data(self,varargin)
        %
        % value = data( 'field' )
        % {value1, value2 ... } = data( {'field1', 'field2' ... } )
        % self = data( 'field1', value1, 'field2', value2 ... );
        %
        
            switch nargin
                case 1
                    out = self.userdat;
                case 2
                    arg = varargin{1};
                    if iscellstr(arg)
                        out = dk.cellfun( @(f)self.userdat.(f), arg, false );
                    else
                        out = self.userdat.(arg);
                    end
                otherwise
                    arg = struct(varargin{:});
                    self.userdat = dk.struct.merge(self.userdat,arg);
                    out = self;
            end
        end
        
    end
    
    methods (Hidden)
        
        function self = Node(varargin)
            self.clear();
            self.assign(varargin{:});
        end
        
        function clear(self)
            self.depth = 0;
            self.parent = [];
            self.children = [];
            self.userdat = struct();
        end
        
        function self=assign(self,depth,parent,varargin)
            self.depth = depth;
            self.parent = parent;
            if nargin > 3
                self.data(varargin{:});
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
classdef Tree2 < handle
    
    properties
        % data array with [parent, depth, nchildren]
        % then struct-array of properties
        % children can be determined dynamically
        
        tree
        data
    end
    
    properties (Transient,Dependent)
        n_nodes, nn
        n_leaves, nl
        n_parents, np
    end
    
    methods
        
        function self = Tree2(varargin)
            self.reset(varargin{:});
        end
        
        function n = get.nn(self), n=self.tree.nrows; end
        function n = get.nl(self), n=nnz( self.tree.data.c('nchildren') == 0 ); end
        function n = get.np(self), n=self.nn - self.nl; end
        
        function n = get.n_nodes(self), n = self.nn; end
        function n = get.n_leaves(self), n = self.nl; end
        function n = get.n_parents(self), n = self.np; end
        
        function reset(self,fields,bsize)
            if nargin < 3, bsize=500; end
            assert( iscellstr(fields), 'Data fields should be predefined.' );
            if isempty(fields), fields = {'none_'}; end
            
            self.tree = dk.obj.DataArray( {'parent','depth','nchildren'}, bsize );
            self.data = dk.struct.repeat( fields, bsize, 1 );
            addlistener( self.tree, 'OnAlloc', @self.updateDataSize );
        end
        
        function x=parent(self,k), x=self.tree.data(k,1); end
        function x=depth(self,k), x=self.tree.data(k,2); end
        function x=nchildren(self,k), x=self.tree.data(k,3); end
        
    end
    
    methods % i/o
        
        
    end
    
    methods % access
        
        % children cell
        function c = chcell(self)
            [p,r] = sort( self.tree.data.c('parent'), 'ascend' );
            k = find(diff(p));
            n = numel(k)-1;
            k = [0,k] + 1;
            c = cell(1,self.nn);
            for i = 1:n
                c{p(k(i))} = r(k(i):k(i+1));
            end
        end
        
        function updateDataSize(self,src,evt)
            n = self.tree.nmax;
            assert( n >= numel(self.data), 'This is a bug.' );
            if n > numel(self.data)
                f = fieldnames(self.data);
                self.data(n).(f{1}) = []; 
            end
        end
        
    end
    
    
end
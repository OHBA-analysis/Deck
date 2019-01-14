classdef BinaryTree < dk.priv.TreeBase
%
% Memory-efficient implementation of Binary Search Tree.
%
% The columns are:
%   key
%   parent
%   depth
%   left
%   right
% 
% JH
    

    properties (Constant)
        type = 'binaryTree';
    end
    
    % utilities
    methods (Hidden)
        
        function k = left(self,k)
            k = self.store.dget(k,4);
        end
        function k = right(self,k)
            k = self.store.dget(k,5);
        end
        
    end
    
    % overload
    methods
        
        % number of children
        function n = nchildren(self,k)
            n = sum(self.store.dget(k,4:5),2);
        end
        function [n,k] = all_nchildren(self)
            n = sum(self.store.col(4:5),2);
            if nargout > 1, k = self.indices(); end
        end
        
        function reset(self,bsize)
            if nargin < 2, bsize=100; end
            colnames = {'key','parent','depth','left','right'};
            self.store = dk.ds.DataArray( colnames, {}, bsize );
        end
        
        function remap = compress(self,res)
            if nargin < 2, res = self.store.bsize; end
            remap = self.store.compress();
            remap = [0; remap(:)]; % allow parent/eldest to be 0
            self.store.data(:,[2,4,5]) = remap(1+self.store.data(:,[2,4,5]));
            self.store.reserve(res);
        end
        
        function [n,p] = get_node(self,k)
            %
        end
        
    end
    
end
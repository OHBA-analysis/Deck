classdef Tree < handle
%
% Tree implementation, using a dk.obj.DataArray as extensible storage.
% The columns of the storage are:
%   parent
%   depth
%   nchildren
%
% Most operations are as efficient as expected, except:
%   list children       O(n)
%   list offspring      O(n log(n))
%   remove node         O(n log(n))
% where n is the total number of nodes. 
%
% Traversal methods are non-recursive.
%
% ----------------------------------------------------------------------
%
% Construction
%
%   T = dk.obj.Tree()                           default root node
%   T = dk.obj.Tree( bsize, Name/Value )        setting the root props
%   T = dk.obj.Tree( serialised_path )          unserialise file
%
% Data-structure
%
%   T.serialise( output_file )
%   T.compress( reserve )
%
% Tree logic
%
%   indices
%   shape
%   levels
%
%   parent(id)      node props (efficient)
%   depth(id)       accept multiple ids
%   nchildren(id)   return vec
%
%   depth()         tree depth           (scalar)   
%   depths()        all node depths      (vec)      
%   nchildrens()    all node #children   (vec)      
%   parents()       all node parents     (cell)     
%
%   offspring ( id, unwrap=false )       inefficient ops O( n log n )
%   children  ( id, unwrap=false )       accept multiple ids
%   siblings  ( id, unwrap=false )       return cell
%   childrens ()
%
% Node logic
%
%   [node,prop] = get_node( id, children=false )   return struct-arrays
%   id = add_node( parent, Name/Value )            
%   removed = rem_node( id )                       remove offspring too
%
%   p = get_props( id )                            struct with all props
%   set_props( id, Name/Value )                    merge with existing
%   rem_props( Names... )                          from all nodes
%
% Traversal
%
%   iter( callback )    
%   dfs ( callback )     with callback( id, node, props )
%   bfs ( callback )
%
% JH

    properties (SetAccess = private, Hidden)
        store
    end
    
    properties (Transient, Dependent)
        n_nodes, nn
        n_leaves, nl
        n_parents, np
        sparsity
    end
    
    methods
        
        function self = Tree(varargin)
            self.clear();
            if nargin > 0
                if ischar(varargin{1})
                    self.unserialise(varargin{1});
                else
                    self.reset(varargin{:});
                end
            end
                
        end
        
        function clear(self)
            self.store = dk.obj.DataArray();
        end
        
        function reset(self,bsize,varargin)
            if nargin < 2, bsize=100; end
            self.store = dk.obj.DataArray( {'parent','depth','nchildren'}, bsize );
            self.store.add( [0,1,0], varargin{:} );
        end
        
        % dependent properties
        function n = get.nn(self), n = self.store.nelm; end
        function n = get.np(self), n = nnz(self.store.col('nchildren')); end
        function n = get.nl(self), n = self.nn - self.np; end
        
        function n = get.n_nodes(self), n = self.nn; end
        function n = get.n_leaves(self), n = self.nl; end
        function n = get.n_parents(self), n = self.np; end
        
        function s = get.sparsity(self), s = self.store.sparsity; end
        function r = ready(self), r = self.nn > 0; end
        
        % compress storage and reindex the tree
        function remap = compress(self,res)
            if nargin < 2, res = self.store.bsize; end
            remap = self.store.compress();
            remap = [0; remap(:)];
            self.store.data(:,1) = remap(1+self.store.data(:,1));
            self.store.reserve(res);
        end
        
        function gobj = plot(self,varargin)
        %
        % Plot tree;
        %   - classic and radial available
        %   - customise nodes and edges
        %   - customise data-tip
        %   - many other options
        % 
        % See help dk.priv.plot_tree for details.
        
            gobj = dk.priv.plot_tree( self, varargin{:} );
        end
        
    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            s.version = '0.1';
            s.store = self.store.serialise();
            if nargin > 1, save(file,'-v7','-struct','s'); end
        end
        
        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case '0.1'
                self.store = dk.obj.DataArray().unserialise( s.store );
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
        function same=compare(self,other)
            same = dk.compare( self.serialise(), other.serialise() );
        end
        
    end
    
    % tree methods
    methods
        
        % node properties
        function k = indices(self)
            k = self.store.find();
        end
        
        function y = isleaf(self,k)
            y = self.nchildren(k) > 0;
        end
        function y = isvalid(self,k)
            y = self.store.used(k);
        end
        
        function p = parent(self,k)
            p = self.store.dget(k,1);
        end
        function [p,k] = parents(self)
            p = self.store.col('parent');
            if nargout > 1
                k = self.indices(); 
            end
        end
        
        function s = siblings(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            s = self.children(self.parent(k),false); % list children of parents
            n = numel(s);
            for i = 1:n
                s{i} = s{i}( s{i} ~= k(i) ); % remove self
            end
            if unwrap && n == 1
                s = s{1};
            end
        end
        
        function d = depth(self,k) 
            if nargin > 1
                d = self.store.dget(k,2);
            else
                % return tree-depth if called without index
                d = max(self.store.col('depth'));
            end
        end
        function [d,k] = depths(self)
            d = self.store.col('depth');
            if nargout > 1
                k = self.indices(); 
            end
        end
        
        function n = nchildren(self,k)
            n = self.store.dget(k,3);
        end
        function [n,k] = nchildrens(self)
            n = self.store.col('parent');
            n = accumarray(n(:),1,size(n));
            if nargout > 1
                k = self.indices(); 
            end
        end
        
        function c = children(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            
            n = numel(k);
            if n > log(1+self.nn)
                c = self.childrens();
                c = c(k);
            else
                c = cell(1,n);
                for i = 1:n
                    % valid nodes whose parent is k(i)
                    c{i} = find(self.store.used & (self.store.data(:,1) == k(i)));
                end
            end
            if unwrap && n==1
                c = c{1};
            end
        end
        function [C,k] = childrens(self)
            [p,k] = self.parents();
            C = dk.util.grouplabels(p,numel(k));
            C = dk.mapfun( @(i) k(i), C, false );
        end
        
        function o = offspring(self,k,unwrap)
        %
        % Most efficient given storage, but pretty slow...
            if nargin < 3, unwrap=true; end
        
            n = numel(k);
            N = self.nchildren(k);
            d = self.depth();
            o = cell(1,n);
            
            if all(N == 0), return; end
            C = self.childrens();
            
            for i = 1:n
                t = cell(1,d);
                t{1} = C{k(i)};
                for j = 2:d
                    t{j} = horzcat(C{t{j-1}});
                    if isempty(t{j}), break; end
                end
                o{i} = horzcat(t{:});
            end
            if unwrap && n == 1
                o = o{1};
            end
        end
        
        
        % tree properties
        function [depth,width] = shape(self)
            depth = self.store.col('depth');    % depth of each node
            width = accumarray( depth(:), 1 );  % width at each depth
            depth = max(depth);                 % depth of the tree
        end
        
        function L = levels(self)
            [d,k] = self.depths();
            L = dk.util.grouplabels(d);
            L = dk.mapfun( @(i) k(i), L, false );
        end
        
        
        % node access
        function [n,m] = root(self,varargin)
            [n,m] = self.get_node(1,varargin{:});
        end
        
        % struct-array nodes (p:parent, d:depth, nc:#children)
        function [n,p] = get_node(self,k,with_children) % works with k vector
            if nargin < 3, with_children=false; end
            
            if nargout > 1
                [d,p] = self.store.both(k);
            else
                d = self.store.row(k);
            end
            n = cell2struct( num2cell(d), {'p','d','nc'}, 2 );
            
            if with_children
                [n.c] = deal(self.children(k,false));
            end
        end
        
        function p = get_props(self,k)
            p = self.store.mget(k);
        end
        function set_props(self,k,varargin)
            self.store.assign(k,varargin{:});
        end
        function rem_props(self,varargin)
            self.store.rmfield(varargin{:});
        end
        
        function k = add_node(self,p,varargin) % works with p vector
            n = numel(p);
            x = [p(:), self.depth(p)+1, zeros(n,1)];
            k = self.store.add( x, varargin{:} );
            self.store.data(p,3) = self.store.data(p,3) + 1; % add to parent count
        end
        function r = rem_node(self,k)
            k = k(:)';
            assert( all(k > 1), 'The root (index 1) cannot be removed.' );
            
            p = self.parent(k);
            o = self.offspring(k,false);
            r = [horzcat(o{:}), k];
            if isempty(k), return; end
            
            self.store.rem(r);
            self.store.data(p,3) = self.store.data(p,3) - 1; % subtract from parent count
        end
        
    end
    
    % traversal methods
    methods
        
        function [out,id] = iter(self,callback)
            id = self.indices();
            if nargout == 0
                dk.mapfun( @(k) callback(k, self.get_node(k), self.get_props(k)), id );
            else
                out = dk.mapfun( @(k) callback(k, self.get_node(k), self.get_props(k)), id, false );
            end
        end
        
        % see: https://stackoverflow.com/a/51124171/472610
        
        function bfs(self,callback,start)
            if nargin < 3, start=1; end
            
            C = self.childrens();
            N = self.nn;
            S = zeros(1,N);
            
            S(1) = start;
            cur = 1;
            last = 1;
            while cur <= last
                id = S(cur);
                callback( id, self.get_node(id), self.get_props(id) );
                
                n = numel(C{id});
                S( last + (1:n) ) = C{id};
                last = last + n;
                cur = cur + 1;
            end
        end
        
        function dfs(self,callback,start)
            if nargin < 3, start=1; end
            
            C = self.childrens();
            N = self.nn;
            S = zeros(1,N);
            
            S(1) = start;
            cur = 1;
            while cur > 0
                id = S(cur);
                callback( id, self.get_node(id), self.get_props(id) );
                
                n = numel(C{id});
                S( cur-1 + (1:n) ) = fliplr(C{id});
                cur = cur-1 + n;
            end
        end
        
    end
    
end
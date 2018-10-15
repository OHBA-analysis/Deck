classdef SplitTree < dk.priv.TreeBase
%
% Tree implementation similar to dk.obj.Tree, but taking advantage of the
% split-context to improve performance. Specifically, the split tree is
% designed for cases where the children of a node are specified together
% at once; no additional children can be created later on, and no node
% can be deleted.
%
% The columns of the storage are:
%   parent
%   depth
%   eldest
%   nchildren
%
% Traversal methods are non-recursive.
%
% ----------------------------------------------------------------------
% ## Usage
%
% Construction
%
%   T = dk.obj.SplitTree()                         default root node
%   T = dk.obj.SplitTree( bsize, Name/Value )      setting the root props
%   T = dk.obj.SplitTree( serialised_path )        unserialise file
%
% Tree logic
%
%   indices()       valid node IDs              (vec)
%   depth()         tree depth                  (scalar)
%   shape()         width at each level         (vec)
%   levels()        group node IDs by level     (cell)
%
%   parent(id)      if of parent node
%   depth(id)       depth of current node (>= 1)
%   eldest(id)      id of the oldest child (or 0)
%   nchildren(id)   number of children
%
%   children  ( id, unwrap=false )       accept multiple ids
%   offspring ( id, unwrap=false )       inefficient ops O( n log n )
%   siblings  ( id, unwrap=false )       return cell
%
%   all_parents()   all node parents     (cell)
%   all_depths()    all node depths      (vec)
%   all_children()  all node children    (cell)
%   all_nchildren() all node #children   (vec)
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
% ----------------------------------------------------------------------
% See also: dk.priv.TreeBase
%
% JH

    properties (Constant)
        type = 'splitTree';
    end

    methods

        function self = SplitTree(varargin)
            self.clear();
            if nargin > 0 && ischar(varargin{1})
                self.unserialise(varargin{1});
            else
                self.reset(varargin{:});
            end
        end
        
        function reset(self,props,bsize)
        %
        % reset( props={}, bsize=100 )
        %
            if nargin < 2, props={}; end
            if nargin < 3, bsize=100; end
            colnames = {'parent','depth','eldest','nchildren'};
            
            if isstruct(props)
                self.store = dk.obj.DataArray( colnames, fieldnames(props), bsize );
                self.store.add( [0,1,0,0], props );
            else
                self.store = dk.obj.DataArray( colnames, props, bsize );
                self.store.add( [0,1,0,0] );
            end
        end

        % compress storage and reindex the tree
        function remap = compress(self,res)
            if nargin < 2, res = self.store.bsize; end
            remap = self.store.compress();
            remap = [0; remap(:)]; % allow parent/eldest to be 0
            self.store.data(:,1) = remap(1+self.store.data(:,1));
            self.store.data(:,3) = remap(1+self.store.data(:,3));
            self.store.reserve(res);
        end

        % special function for split-trees
        % gives the order of current nodes relative to oldest sibling
        % accept root
        function [r,p] = order(self,k)
            p = self.parent(k);
            m = p > 0;
            r = 0 + ~m;
            r(m) = k(m) - self.eldest(p(m)) + 1;
        end
        function [r,k] = all_orders(self)
            k = self.indices();
            r = self.order(k);
        end

        function e = eldest(self,k)
            e = self.store.dget(k,3);
        end
        function [e,k] = all_eldests(self)
            e = self.store.col('eldest');
            if nargout > 1, k = self.indices(); end
        end

        function n = nchildren(self,k)
            n = self.store.dget(k,4);
        end
        function [n,k] = all_nchildren(self)
            n = self.store.col('nchildren');
            if nargout > 1, k = self.indices(); end
        end

        % child socket = (first, last)
        % accept k <= 0
        function r = crange(self,k)
            n = numel(k);
            m = k(:) > 0;
            r = zeros(n,2);
            r(m,:) = self.store.dget(k(m),3:4);
            r = [ r(:,1), r(:,1) + r(:,2) - 1 ];
        end
        function [r,k] = all_crange(self)
            r = self.store.col(3:4);
            r = [ r(:,1), r(:,1) + r(:,2) - 1 ];
            if nargout > 1, k = self.indices(); end
        end

        function c = children(self,k,unwrap)
            if nargin < 3, unwrap=true; end

            d = self.crange(k);
            n = numel(k);
            c = dk.mapfun( @(i) d(i,1):d(i,2), 1:n, false );
            if unwrap && n==1
                c = c{1};
            end
        end
        function [c,k] = all_children(self)
            k = self.indices();
            c = self.children( k, false );
        end

        function s = siblings(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            [r,p] = self.order(k);
            c = self.crange(p); % list children of parents
            n = numel(k);
            s = cell(1,k);

            notb = @(a,b) (a(1)-1) + [ 1:b-1, b+1:(a(2)-a(1)+1) ];
            for i = 1:n
                s{i} = notb( c(i,:), r(i) );
            end
            if unwrap && n == 1
                s = s{1};
            end
        end

        function o = offspring(self,k,unwrap)
            if nargin < 3, unwrap=true; end

            n = numel(k);
            d = self.depth();
            o = cell(1,n);
            x = cell(1,d);
            C = self.children(k);

            for i = 1:n
                ci = C(i,:);
                di = 0;
                while ~isempty(ci)
                    di = di+1;
                    x{di} = ci;
                    ci = self.children(x{di});
                    ci = [ci{:}];
                end
                o{i} = [x{1:di}];
            end

            if unwrap && n == 1
                o = o{1};
            end
        end

        % struct-array nodes (p:parent, d:depth, c:children, nc:#children)
        function [n,p] = get_node(self,k,with_children) % works with k vector
            if nargin < 3, with_children=false; end
            if nargout > 1
                [d,p] = self.store.both(k);
            else
                d = self.store.row(k);
            end
            n = cell2struct( num2cell(d(:,[1,2,4])), {'p','d','nc'}, 2 );

            if with_children
                [n.c] = dk.deal(self.children(k,false));
            end
        end

        % split multiple nodes
        function k = split(self,p,n,varargin)
            p = p(:);
            n = n(:);
            m = numel(p);
            u = unique(p);

            assert( all(n > 0), 'Number of children should be positive.' );
            assert( all(numel(u) == m), 'Doublons not allowed.' );
            assert( all(self.is_valid(p)), 'Invalid parent node.' );
            assert( all(self.is_leaf(p)), 'Nodes can only be split once.' );

            % repeat parents according to n
            t = 1 + cumsum([ 0; n ]);
            L(t) = 1;
            L = cumsum(L(1:end-1));

            x = p(L);
            x = [x(:), self.depth(x)+1, zeros(sum(n),2)];
            k = self.store.add( x, varargin{:} );

            self.store.data(p,3) = k(t(1:end-1));
            self.store.data(p,4) = n;
        end

    end

    % traversal methods
    methods

        % see: https://stackoverflow.com/a/51124171/472610
        %
        % More efficient implementation, given storage.

        function bfs(self,callback,start)
            if nargin < 3, start=1; end

            N = self.nn;
            S = zeros(1,N);

            S(1) = start;
            cur = 1;
            last = 1;
            while cur <= last
                id = S(cur);
                callback( id, self.get_node(id), self.get_props(id) );
                c = self.crange(id);
                n = c(2)-c(1)+1;
                S( last + (1:n) ) = c(1):c(2);
                last = last + n;
                cur = cur + 1;
            end
        end

        function dfs(self,callback,start)
            if nargin < 3, start=1; end

            N = self.nn;
            S = zeros(1,N);

            S(1) = start;
            cur = 1;
            while cur > 0
                id = S(cur);
                callback( id, self.get_node(id), self.get_props(id) );
                c = self.crange(id);
                n = c(2)-c(1)+1;
                S( cur-1 + (1:n) ) = fliplr(c(1):c(2));
                cur = cur-1 + n;
            end
        end

    end

end

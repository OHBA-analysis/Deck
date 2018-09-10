classdef SplitTree < dk.obj.Tree
%
% Tree implementation similar to dk.obj.Tree, but taking advantage of the
% split-context to improve performance. Specifically, the split tree is
% designed for cases where the children of a node are specified together
% at once; no additional children can be created later on.
%
% The columns of the storage are:
%   parent
%   depth
%   eldest
%   nchildren
%
% Traversal methods are non-recursive.
%
%
% ----------------------------------------------------------------------
% ## Usage
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

    methods

        function self = SplitTree(varargin)
            self.clear();
            if nargin > 0 && ischar(varargin{1})
                self.unserialise(varargin{1});
            else
                self.reset(varargin{:});
            end
        end

        function reset(self,bsize,varargin)
            if nargin < 2, bsize=100; end
            self.store = dk.obj.DataArray( {'parent','depth','eldest','nchildren'}, bsize );
            self.store.add( [0,1,0,0], varargin{:} );
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

    end

    % tree methods
    methods

        % special function for split-trees
        % gives the order of current nodes relative to oldest sibling
        function [r,p] = order(self,k)
            p = self.parent(k);
            r = k(:) - self.eldest(p) + 1;
        end
        function [r,k] = allOrders(self)
            k = self.indices();
            r = self.order(k);
        end

        function e = eldest(self,k)
            e = self.store.dget(k,3);
        end
        function [e,k] = allEldests(self)
            e = self.store.col('eldest');
            if nargout > 1, k = self.indices(); end
        end

        function n = nchildren(self,k)
            n = self.store.dget(k,4);
        end
        function [n,k] = allNchildren(self)
            n = self.store.col('nchildren');
            if nargout > 1, k = self.indices(); end
        end

        function c = children(self,k,unwrap)
            if nargin < 3, unwrap=true; end

            d = self.store.dget(k,3:4);
            d(:,1) = max( d(:,1), 1 );
                % this allows us not to worry about eldest=0
                % because we know that nchildren=0 too then

            n = numel(k);
            c = dk.mapfun( @(i) d(i,1):d(i,2), 1:n, false );
            if unwrap && n==1
                c = c{1};
            end
        end
        function [C,k] = allChildren(self)
            k = self.indices();
            C = self.children( k, false );
        end

        function s = siblings(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            [r,p] = self.order(k);
            s = self.children(p,false); % list children of parents
            n = numel(s);

            remk = @(x,k) [ x(1:k-1), x(k+1:end) ];
            for i = 1:n
                s{i} = remk( s{i}, r(i) ); % remove self
            end
            if unwrap && n == 1
                s = s{1};
            end
        end

        function o = offspring(self,k,unwrap)
            if nargin < 3, unwrap=true; end

            E = self.eldest
            n = numel(k);
            o = cell(1,n);

            for i = 1:n

                % relative depth
                d = 0;

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

        % struct-array nodes (p:parent, d:depth, c:children, nc:#children)
        function [n,p] = get_node(self,k) % works with k vector
            if nargout > 1
                [d,p] = self.store.both(k);
            else
                d = self.store.row(k);
            end
            n = cell2struct( num2cell(d), {'p','d','nc'}, 2 );
            [n.c] = deal(self.children(k,false));
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

        function add_node(~,varargin) % works with p vector
            error('not available')
        end
        function r = rem_node(self,k)
            error('not available')
        end

        function k = split_node(self,p,varargin)
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
            [~,r] = self.indices();

            S(1) = start;
            cur = 1;
            last = 1;
            while cur <= last
                id = S(cur);
                callback( id, self.get_node(id), self.get_props(id) );
                n = numel(C{r(id)});
                S( last + (1:n) ) = C{r(id)};
                last = last + n;
                cur = cur + 1;
            end
        end

        function dfs(self,callback,start)
            if nargin < 3, start=1; end

            C = self.childrens();
            N = self.nn;
            S = zeros(1,N);
            [~,r] = self.indices();

            S(1) = start;
            cur = 1;
            while cur > 0
                id = S(cur);
                callback( id, self.get_node(id), self.get_props(id) );
                n = numel(C{r(id)});
                S( cur-1 + (1:n) ) = fliplr(C{r(id)});
                cur = cur-1 + n;
            end
        end

    end

end
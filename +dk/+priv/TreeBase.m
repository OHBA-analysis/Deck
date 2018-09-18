classdef TreeBase < handle
%
% Base class for tree implementations, using a dk.obj.DataArray as storage.
% See below for methods to be implemented in derived classes.
%
% ----------------------------------------------------------------------
% ## Usage
%
% Data-structure
%
%   T.serialise( output_file )
%   T.compress( reserve )
%
% Tree logic
%
%   indices()       valid node IDs              (vec)
%   depth()         tree depth                  (scalar)
%   shape()         width at each level         (vec)
%   levels()        group node IDs by level     (cell)
%
%   parent(id)      node props (efficient)
%   depth(id)       accept multiple ids
%
%   children  ( id, unwrap=false )       accept multiple ids
%   offspring ( id, unwrap=false )       inefficient ops O( n log n )
%   siblings  ( id, unwrap=false )       return cell
%
%   all_parents()   all node parents     (cell)
%   all_depths()    all node depths      (vec)
%   all_children()  all node children    (cell)
%
% Node logic
%
%   [node,prop] = get_node(id)           return struct-arrays
%
%   p = get_props( id )                  struct with all props
%   set_props( id, Name/Value )          merge with existing
%   rem_props( Names... )                from all nodes
%
% Traversal
%
%   iter( callback )
%   dfs ( callback )     with callback( id, node, props )
%   bfs ( callback )
%
% JH

    properties (SetAccess=protected, Hidden)
        store
    end

    properties (Transient, Dependent)
        n_nodes
        n_leaves
        n_parents
        sparsity
    end
    properties (Transient, Dependent, Hidden)
        nn, nl, np
    end

    properties (Abstract,Constant)
        type
    end

    methods (Abstract)

        % rootprops is either:
        %   a cell of property names, or 
        %   a struct of properties
        reset(self,rootprops,bsize);

        % re-index the tree to remove unused nodes
        remap = compress(self,res);

        % struct-array nodes (p:parent, d:depth, nc:#children)
        [n,p] = get_node(self,k)

        o = offspring(self,k);
        s = siblings(self,k);
        c = children(self,k);
        [c,k] = all_children(self);

    end

    methods

        function clear(self)
            self.store = dk.obj.DataArray();
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

        function gobj = plot(self,varargin)
        %
        % Plot tree;
        %   - classic and radial available
        %   - customise nodes and edges
        %   - customise data-tip
        %   - many other options
        %
        % See also: dk.priv.draw_tree

            gobj = dk.priv.draw_tree( self, varargin{:} );
        end

        function print(self,varargin)
        %
        % Display tree in console, or write to file.
        %
        % See also: dk.priv.disp_tree

            dk.priv.disp_tree( self, varargin{:} );
        end

    end

    % i/o
    methods

        function s=serialise(self,file)
            s.version = '0.1';
            s.type = self.type;
            s.store = self.store.serialise();
            if nargin > 1, save(file,'-v7','-struct','s'); end
        end

        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        dk.assert( strcmpi(s.type,self.type), 'Type mismatch: %s != %s', s.type, self.type );
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
        function [k,r] = indices(self)
            k = self.store.find();
            if nargout > 1
                r(k) = 1:numel(k); % reverse mapping
            end
        end

        function y = is_leaf(self,k)
            y = self.nchildren(k) == 0;
        end
        function y = is_valid(self,k)
            y = self.store.used(k);
        end

        function p = parent(self,k)
            p = self.store.dget(k,'parent');
        end
        function [p,k] = all_parents(self)
            p = self.store.col('parent');
            if nargout > 1, k = self.indices(); end
        end

        function d = depth(self,k)
            % return tree-depth if called without index
            if nargin > 1
                d = self.store.dget(k,'depth');
            else
                d = max(self.store.col('depth'));
            end
        end
        function [d,k] = all_depths(self)
            d = self.store.col('depth');
            if nargout > 1, k = self.indices(); end
        end

        % tree properties
        function [width,depth] = shape(self)
            depth = self.store.col('depth');    % depth of each node
            width = accumarray( depth(:), 1 );  % width at each depth
            depth = max(depth);                 % depth of the tree
        end

        function L = levels(self)
            [d,k] = self.all_depths();
            L = dk.util.grouplabels(d);
            L = dk.mapfun( @(i) k(i), L, false );
        end


        % node access
        function [n,m] = root(self,varargin)
            [n,m] = self.get_node(1,varargin{:});
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
        %
        % These implementations are reasonably efficient without assumptions about the
        % type of tree; they can be overridden in derived classes if needed.

        function bfs(self,callback,start)
            if nargin < 3, start=1; end

            C = self.all_children();
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

            C = self.all_children();
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

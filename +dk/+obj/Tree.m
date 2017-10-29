classdef Tree < handle
    
    properties
        node
    end

    properties (Transient,Dependent)
        n_nodes, n_leaves, n_parents;
    end
    
    % dependent properties
    methods
        function v=valid(self) % quick function to find valid nodes
            v=[self.node.depth] > 0;
        end
        
        function n=get.n_nodes(self)
            n=sum(self.valid());
        end
        function n=get.n_leaves(self)
            n=sum(self.valid() & [self.node.is_leaf]);
        end
        function n=get.n_parents(self)
            n=sum(self.valid() & ~[self.node.is_leaf]);
        end
    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            s.version = '0.1';
            s.node = dk.arrayfun( @(n) n.serialise(), self.node, false );
            if nargin > 1, save(file,'-v7','-struct','s'); end
        end
        
        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case '0.1'
                self.node = dk.cellfun( @(n) dk.obj.Node(n), s.node, false );
                self.node = [self.node{:}];
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
        function same=compare(self,other)
            same = dk.compare( self.serialise(), other.serialise() );
        end
        
    end
    
    % setup
    methods
        
        function self = Tree(varargin)
            self.reset(varargin{:});
        end
        
        function self=reset(self,varargin)
            % set root node
            self.node = dk.obj.Node(1,1,varargin{:});
        end
        
        % remove deleted nodes and re-index the tree
        function self=cleanup(self)
            
            depth = [self.node.depth];
            valid = depth > 0;
            
            % remap depth (this should not happen)
            count = accumarray( 1+depth(:), 1 );
            assert( all(count(2:end) > 0), 'Bug during removal.' );
            
            % remap valid indices, and sort by depth
            [~,order] = sort(depth(valid));
            old2new = zeros(size(self.node));
            old2new(valid) = order;
            
            self.node = self.node(valid);
            n = numel(self.node);
            for i = 1:n
                self.node(i).remap( old2new );
            end
            
        end
        
    end
    
    % main
    methods
        
        % shape of the tree
        function [depth,width] = shape(self)
            depth = nonzeros([self.node.depth]);
            width = accumarray( depth(:), 1 );
            depth = max(depth);
        end
        
        % add/remove single node
        function k=add_node(self,p,varargin)
            k = length(self.node)+1;
            d = self.node(p).depth+1;
            self.node(k) = dk.obj.Node(d,p,varargin{:});
            self.node(p).add_child(k);
        end
        function self=rem_node(self,k)
            % cannot remove node from array without screwing up indices, use cleanup
            assert( k > 1, 'Cannot remove the root, use reset() instead.' );
            self.parent(k).rem_child(k);
            c = self.node(k).children;
            for i = 1:length(c)
                self.rem_node(c(i));
            end
            self.node(k).clear();
        end
        
        % add/remove multiple nodes
        function k=add_nodes(self,p,n)
            k = zeros(1,n);
            for i = 1:n
                k(i) = self.add_node(p);
            end
        end
        function rem_nodes(self,k)
            for i = 1:numel(k)
                self.rem_node(k(i));
            end
        end
        
        % proxy for node properties
        function N=root(self)
            N=self.node(1);
        end
        function p=parent(self,k)
            p=self.node( self.node(k).parent );
        end
        function N=children(self,k)
            N=self.node( self.node(k).children );
        end
        
        function [L,N] = levels(self)
        % 
        % [L,N] = levels(self)
        %
        % Group nodes by level, and return a cell with indices for each level.
        % If second output is collected, it contains a cell of node-structs.
        % 
        % JH
        
            depth = [self.node.depth];
            valid = find([self.node.is_valid]);
            
            [depth,order] = sort(depth(valid),'ascend');
            valid = valid(order);
            stride = [find(diff(depth)==1), numel(depth)];
            
            n = numel(stride);
            L = cell(1,n);
            e = 0;
            for i = 1:n
                b = e+1;
                e = stride(i);
                L{i} = valid(b:e);
            end
            
            if nargout > 1
                N = dk.cellfun( @(ind) self.node(ind), L, false );
            end
        end
        
        function N = level(self,D)
        %
        % N = level(self,D)
        %
        % Get a struct-array of nodes at a given depth.
        %
        % JH
        
            N = self.node( [self.node.depth] == D );
        end
        
        function [C,N] = descent(self,k)
        %
        % C = descent(self,k)
        %
        % List of node indices for all nodes descending from node k.
        % If second output is requested, then the function returns a vector
        % with the corresponding nodes.
        %
        % JH
        
            C = {};
            t = self.node(k).children;
            
            while ~isempty(t)
                C{end+1} = t; %#ok
                t = [ self.node(t).children ];
            end
            
            C = [C{:}];
            if nargout > 1
                N = self.node(C);
            end

        end
        
        
        % traversal methods
        function bfs(self,callback,cur)
        %
        % bfs(self,callback)
        %
        % Breadth-first traversal methods.
        % Note that the order of traversal is not guaranteed.
        % The callback function is called as follows:
        %
        %   callback( node_index, node )
        %
        
            if nargin < 3, cur = 1; end
            next = cell(size(cur));
            for i = 1:length(cur)
                curnode = self.node(cur(i));
                callback(cur(i), curnode);
                next{i} = curnode.children;
            end
            next = unique(horzcat( next{:} ));
            if ~isempty(next)
                self.bfs( callback, next );
            end
        end
        function dfs(self,callback,cur)
        %
        % dfs(self,callback)
        %
        % Depth-first traversal methods.
        % Note that the order of traversal is not guaranteed.
        % The callback function is called as follows:
        %
        %   callback( node_index, node )
        %
        
            if nargin < 3, cur=1; end
            assert( isscalar(cur), 'Expected a single node.' );
            curnode = self.node(cur);
            callback(cur, curnode);
            next = curnode.children;
            for i = 1:length(next)
                self.dfs( callback, next(i) );
            end
        end
        
        function print(self,fid)
        %
        % print(self,fid)
        %
        % Print to file (or console by default).
        % Each line has one of the two following format:
        %
        %   ParentID>NodeID [Depth] : NChildren children, NFields data-fields
        %   #NodeID [Depth] : DELETED
        % 
        %JH
        
            if nargin < 2, fid=1; end
            N = self.n_nodes;
            for i = 1:N 
                Ni = self.node(i);
                if Ni.is_valid
                    fprintf( fid, '%d>%d [%d] : %d children, %d data-fields\n', ...
                        Ni.parent, i, Ni.depth, numel(Ni.children), numel(Ni.fields) );
                else
                    fprintf( fid, '#%d [%d] : DELETED\n', i, Ni.depth );
                end
            end
        end
        
        function gobj = plot(self,varargin)
        %
        % gobj = plot(self,varargin)
        %
        % Draw the tree.
        %
        % Options:
        %
        %      Newfig  Open new figure to draw.
        %             >Default: true
        %        Link  Link options (cf Line properties)
        %             >Default: {} (none)
        %      Sepfun  Function of the depth adding width to separate branches
        %             >Default: @(x)x/10 or @(x)zeros(size(x))
        %     Balance  Balancing flag (children reordering)
        %             >Default: true
        %    NodeSize  Size of the node
        %             >Default: 0.2
        %   NodeColor  Face-color of the node
        %             >Default: hsv colormap
        %    NodeEdge  Colour of the edges
        %             >Default: 'k'
        %     ToolTip  Function handle to be called by datacursormode
        %             >Default: shows "id: NodeID"
        %      Radial  Flag to draw the tree with radial geometry
        %             >Default: false
        %
        % JH
            
            opt = dk.obj.kwArgs(varargin{:});
            radial = opt.get('Radial',false);
            balance = opt.get('Balance',true);
            
            % compute widths
            if radial
                sepfun = opt.get( 'Sepfun', @(x)x/10 );
            else
                sepfun = opt.get( 'Sepfun', @(x)zeros(size(x)) );
            end
            nodes = self.compute_widths(sepfun);
            
            % drawing properties
            defcol = hsv(max( nodes.d, 6 ));
            linkopt = opt.get('Link', {} );
            nodes = add_prop( nodes, ...
                opt.get('NodeSize',0.2), ...
                opt.get('NodeColor',dk.cmap.interp( defcol, nodes.depth )), ...
                opt.get('NodeEdge','k') ...
            );
        
            % draw the tree
            if opt.get('Newfig',true)
                figure('Color','w','Name','[dk] Tree plot');
            end
            if radial
                gobj = self.radial_draw(nodes,balance,linkopt);
            else
                gobj = self.vertical_draw(nodes,balance,linkopt);
            end
            
            % set data tip
            tooltip = opt.get( 'ToolTip', @datatip );
            set( datacursormode(gcf), 'updatefcn', tooltip );
            
        end
        
    end
    
    % utils
    methods (Hidden)
        
        function nodes = compute_widths(self,sepfun)
        %
        % Compute the width required for displaying each node and its children.
        % The leaf nodes have a width of 1, which is equivalent to right and left margins of 1/2.
        %
        % The width of leaf nodes is propagated to their parents (summing for all children), then 
        % to their grandparents, etc. Until we reach the root. 
        % Note that this _needs_ to be done level by level.
        %
        % Sepfun is used to insert a space between different families at each level. 
        % This is done indirectly by adding width to nodes that are closer to the root. Then when
        % we draw the nodes, the discrepancy between the width of the children, and that of the 
        % parent, is the separation increment.
        %
        % The outputs are:
        %   nod  Struct-array with fields {w,d,k} (width,depth,index) for each valid node.
        %   tot  Total width at each depth (smaller vector).
        %
        % JH

            depth = [self.node.depth];
            valid = [self.node.is_valid];
            leaf  = [self.node.is_leaf];
            
            n = sum(valid);
            d = depth(valid);
            maxd = max(d);
            inc = sepfun(fliplr(0:maxd-1));

            % initialise width
            k = find(valid);
            w = zeros(1,n);
            w(leaf(valid)) = 1; % set all leaves to 1

            % propagate width level by level, starting from the bottom
            for h = maxd:-1:2
                c = k( d == h );
                p = [self.node(c).parent];
                m = numel(c);

                for i = 1:m
                    w(c(i)) = w(c(i)) + inc(h);
                    w(p(i)) = w(p(i)) + w(c(i));
                end
            end
            
            % compute total width for each level
            tot = accumarray( d(:), w(:), [maxd,1] );
            
            % pack all this information
            map(k) = 1:n; %disp(w)
            nodes = struct( 'n', n, 'd', max(depth), ...
                'width', w, 'depth', d, 'index', k, 'lw', tot, 'map', map );

        end
        
        % draw tree with a vertical layout
        function gobj = vertical_draw(self,nodes,balance,linkopt)

            N = nodes.n;
            D = nodes.d;
            W = nodes.width;
            %H = W(1) ./ log2(1+(1:D));
            H = W(1) ./ sqrt(1:D);

            % axis coordinate and offset for each node
            coord = zeros(1,N);
            offset = zeros(1,N);

            % open new figure for display
            gobj.node = gobjects(1,N);
            gobj.link = gobjects(1,N); % first link is null

            % draw the root
            coord(1) = W(1)/2;
            gobj.node(1) = draw_node( W(1)/2, H(1), nodes.prop(1) );
            hold on;

            % draw tree level by level, starting from the root
            for d = 1:D-1

                % find nodes at that level, and their children
                p = nodes.index( nodes.depth == d );

                % draw the children of each parent
                y = H(d+1);
                np = numel(p);
                for j = 1:np

                    % skip if there are no children
                    pj = p(j);
                    kj = nodes.map(pj);
                    if self.node(pj).is_leaf, continue; end

                    % reorder children to balance the tree
                    cj = self.node(pj).children;
                    wj = W(nodes.map(cj));
                    nc = numel(cj);
                    if balance
                        cj = reorder_children( cj, wj );
                    end

                    % draw the children in order
                    x0 = offset(kj); % offset of the parent
                    x0 = x0 + (W(kj) - sum(wj))/2; % add separation increment
                    for i = 1:nc
                        cji = cj(i); 
                        kji = nodes.map(cji);

                        % save position of current node
                        offset(kji) = x0;
                        coord(kji) = x0 + W(kji)/2;

                        % update offset for siblings
                        x0 = x0 + W(kji);

                        % draw node and link to parent
                        glink = draw_link( coord(kji), y, coord(kj), H(d), linkopt );
                        gnode = draw_node( coord(kji), y, nodes.prop(kji) );

                        % set datatip
                        gnode.UserData.id = cji;
                        glink.UserData.id = pj;
                        
                        % save handles
                        gobj.node(kji) = gnode;
                        gobj.link(kji) = glink;
                    end
                end

                %fprintf('Level %d\n',d);
            end
            hold off; axis equal tight off;

        end
        
        % draw tree with radial layout
        function gobj = radial_draw(self,nodes,balance,linkopt)
            
            N = nodes.n;
            D = nodes.d;
            W = nodes.width;
            L = max(nodes.lw);
            
            maxd = max(D);
            R = 0:maxd-1;
            %R = R.*log1p(R);
            %R = R.*sqrt(R);
            F = 0.85;

            % axis coordinate and offset for each node
            angle = zeros(1,N);
            offset = zeros(1,N);

            % open new figure for display
            gobj.node = gobjects(1,N);
            gobj.link = gobjects(1,N); % first link is null

            % draw the root
            angle(1) = 0;
            gobj.node(1) = draw_node( 0, 0, nodes.prop(1) );
            hold on;

            % draw tree level by level, starting from the root
            for d = 1:D-1

                % find nodes at that level, and their children
                p = nodes.index( nodes.depth == d );
                
                % draw the children of each parent
                r = R(d+1);
                f = F;
                np = numel(p);
                for j = 1:np

                    % skip if there are no children
                    pj = p(j);
                    kj = nodes.map(pj);
                    aj = angle(kj);
                    if self.node(pj).is_leaf, continue; end

                    % reorder children to balance the tree
                    cj = self.node(pj).children;
                    wj = W(nodes.map(cj));
                    nc = numel(cj);
                    if balance
                        cj = reorder_children( cj, wj );
                    end

                    % draw the children in order
                    x0 = offset(kj); % offset of the parent
                    x0 = x0 + (W(kj) - sum(wj))/2;
                    for i = 1:nc
                        cji = cj(i); 
                        kji = nodes.map(cji);

                        % save position of current node
                        offset(kji) = x0;
                        angle(kji) = 2*pi*f*(x0 + W(kji)/2)/L - pi*(0.5 + f);

                        % update offset for siblings
                        x0 = x0 + W(kji);
                        aji = angle(kji);

                        % draw node and link to parent
                        glink = draw_link( r*cos(aji), r*sin(aji), R(d)*cos(aj), R(d)*sin(aj), linkopt );
                        gnode = draw_node( r*cos(aji), r*sin(aji), nodes.prop(kji) );

                        %fprintf( 'Node %d: %.2f\n', kji, 180*aji/pi );
                        
                        % set datatip
                        gnode.UserData.id = cji;
                        glink.UserData.id = pj;
                        
                        % save handles
                        gobj.node(kji) = gnode;
                        gobj.link(kji) = glink;
                    end
                end

                %fprintf('Level %d\n',d);
            end
            hold off; axis equal tight off;
            
        end
        
    end
    
end

% Isolate functions which actually draw stuff.
function h = draw_node2(x,y,p)
    opt = { 'MarkerSize', p.size, 'MarkerFaceColor', p.face, 'MarkerEdgeColor', p.edge };
    h = plot(x,y,'o',opt{:});
end
function h = draw_node3(x,y,p)
    opt = { 'FaceColor', p.face, 'EdgeColor', p.edge, 'LineWidth', 0.2 };
    h = dk.ui.circle( [x,y], p.size, opt{:} );
end
function h = draw_node(x,y,p)
    opt = { 'EdgeColor', p.edge, 'LineWidth', 0.2 };
    h = dk.ui.disk( [x,y], p.size, 31, p.face, opt{:} );
end

function h = draw_link(x,y,xx,yy,opt)
    h = plot([x,xx],[y,yy],'k-',opt{:});
end

% make sure that input has n rows
function x = check_size(x,n)
    if iscell(x), x = vertcat(x{:}); end
    if ischar(x) || size(x,1) < n
        x = repmat(x,n,1);
    end
    assert( numel(x)==n || size(x,1)==n, 'Bad input size.' );
end

% create struct-array of node properties
function nodes = add_prop(nodes,sz,fc,ec)

    n = nodes.n;
    assert( isnumeric(sz), 'Size should be numeric.' );
    if numel(sz) < n, sz = sz*ones(n,1); end
    assert( numel(sz)==n, 'Bad input size.' );
    
    fc = check_size(fc,n);
    ec = check_size(ec,n);
    
    prop = dk.struct.repeat( {'size','face','edge'}, 1, n );
    for i = 1:n
        prop(i).size = sz(i);
        prop(i).face = fc(i,:);
        prop(i).edge = ec(i,:);
    end
    nodes.prop = prop;
    
end

function txt = datatip(~,evt)
    try
        dat = evt.Target.UserData;
        txt = { ['id: ' num2str(dat.id)] };
    catch
        txt = 'Undefined';
    end
end

function c = reorder_children( c, w )
%
% Simple balancing technique which distributes weights in decreasing order, 
% starting at the centre and alternating right and left.
%

    n = numel(c);
    if n == 1, return; end
    
    [~,o] = sort(w,'descend');
    r = zeros(1,n);
    p = ceil(n/2);

    for i = 1:n
        if mod(i,2) == 1 % odd
            r( p - (i-1)/2 ) = c(o(i));
        else
            r( p + i/2 ) = c(o(i));
        end
    end
    c = r;
    
end
